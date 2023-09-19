import Production from "../models/productionModel.js";
import Product from "../models/productModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import Type from "../models/typeModel.js";
// import ProductColor from "../models/productColorModel.js";
import Color from "../models/colorModel.js";
import { createLog } from "../functions/createLog.js";

export const getProductionByCode = async(req, res) => {
    var _productionCode = req.query["productionCode"];
    try {
        await Production.findAll({
            order: [['productionDate', 'DESC']],
            include: [{
                    model: Product,
                    required: false,
                    include: [{
                        model: Type,
                        required: true
                    }]
                },
                {
                    model: FabricatingMaterial,
                    required: false,
                },
                
            ],
            where: {
                productionCode: _productionCode,
            },
        }, {
            subQuery: false,
        }).then((response) => {
            if (response.length > 0) {
                return res.json({
                    message: "Data semua pemasukan produksi berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data pemasukan produksi",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const getProductionGrouped = async(req, res) => {
    try {
        await Production.findAll({
            order: [['productionDate', 'DESC']],
            include: [{
                    model: Product,
                    required: false,
                    include: [{
                        model: Type,
                        required: true
                    }]
                },
                {
                    model: FabricatingMaterial,
                    required: false,
                },
            ],
            group: "productionCode",
        }, {
            subQuery: false,
        }).then((response) => {
            if (response.length > 0) {
                return res.json({
                    message: "Data semua pemasukan produksi berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data pemasukan produksi",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const getProductions = async(req, res) => {
    try {
        await Production.findAll({
            order: [['productionDate', 'DESC']],
            include: [{
                    model: Product,
                    required: false,
                    include: [{
                        model: Type,
                        required: true
                    }]
                    // include: [
                    //     // {
                    //     //   model: ProductColor,
                    //     //   required: false,
                    //     //   include: [
                    //     //     {
                    //     //       model: Color,
                    //     //       required: false,
                    //     //     },
                    //     //   ],
                    //     // },
                    //     {
                    //         model: Color,
                    //         required: true,
                    //     },
                    //     {
                    //         model: Type,
                    //         required: true,
                    //     },
                    // ],
                },
                {
                    model: FabricatingMaterial,
                    required: false,
                },
            ],
        }, {
            subQuery: false,
        }).then((response) => {
            if (response.length > 0) {
                return res.json({
                    message: "Data semua produksi berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data pembayaran",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const createProduction = async(req, res) => {
    const dateNow = Date.now();
    var _materials = req.body.materials;
    try {
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }

        if (_materials.length != 0) {
            
                // console.log(material.supplierId)
                await Production.create({
                    productionCode: req.body.productionCode,
                    productionDate: req.body.productionDate,
                    productionQty: req.body.productionQty,
                    productId: _materials[0].productId,
                    fabricatingMaterialId: _materials[0].fabricatingMaterialId,
                    productionDesc: req.body.productionDesc,
                    
                }).then(async(_) => {
                    if (_materials[0].productId != null) {
                        var originalMaterial = await Product.findOne({
                            where: {
                                productId: _materials[0].productId,
                            },
                        }, {
                            subQuery: false,
                        });
                        Product.update({
                            productQty: String(
                                parseInt(originalMaterial.productQty) + parseInt(req.body.productionQty)
                            ),
                        }, {
                            where: {
                                productId: _materials[0].productId,
                            },
                        });
                    }
                    if (_materials[0].fabricatingMaterialId != null) {
                        var originalMaterial = await FabricatingMaterial.findOne({
                            where: {
                                fabricatingMaterialId: _materials[0].fabricatingMaterialId,
                            },
                        }, {
                            subQuery: false,
                        });
                        FabricatingMaterial.update({
                            fabricatingMaterialQty: String(
                                parseInt(originalMaterial.fabricatingMaterialQty) + parseInt(req.body.productionQty)
                            ),
                        }, {
                            where: {
                                fabricatingMaterialId: _materials[0].fabricatingMaterialId,
                            },
                        });
                    }
                });
            
            createLog(req.userId, "Produksi", "Produksi Baru")
            return res.json({
                message: "Berhasil membuat produksi!",
                status: "success",
            });
        } else {
            throw "error materials";
        }
    } catch (error) {
        var message = "";
        var field = "";
        console.log(error)
        if (error == "error materials") {
            return res.json({
                message: "Pilih Kategori dan Masukkan 1 Barang",
                status: "error",
            });
        } else {
            // Field checking
            if (error.errors[0].path == "productionCode") {
                field = "Kode produksi produk";
            } else if (error.errors[0].path == "productionDate") {
                field = "Tanggal produksi produk";
            } else if (error.errors[0].path == "productId") {
                field = "Data produk";
            } else if (error.errors[0].path == "productionQty") {
                field = "Kuantiti produksi produk";
            } else if (error.errors[0].path == "fabricatingMaterialId") {
                field = "Data bahan setengah jadi";
            }
            // Set a message
            if (error.errors[0].type == "unique violation") {
                message = field + " " + error.errors[0].value + " sudah terpakai";
            } else if (error.errors[0].type == "notNull Violation") {
                message = field + " tidak boleh kosong";
            }
            return res.json({ message: message, status: "error" });
        }
    }
};

export const deleteProduction = async(req, res) => {
    try {
        console.log("KUSO")
        var _productionCode = req.query["productionCode"];
        var productions = await Production.findAll({
            order: [['productionDate', 'DESC']],
            include: [{
                    model: Product,
                    required: false,
                    include: [{
                        model: Type,
                        required: true
                    }]
                },
                {
                    model: FabricatingMaterial,
                    required: false,
                },
                
            ],
            where: {
                productionCode: _productionCode,
            },
        })
        for (const production of productions){
            console.log("KUSO : " + production.productId);
            if(production.productId != null){
                var originalMaterial = await Product.findOne({
                    where: {
                        productId: production.productId,
                    },
                }, {
                    subQuery: false,
                });
                Product.update({
                    productQty: String(
                        parseInt(originalMaterial.productQty) - parseInt(production.productionQty)
                    ),
                }, {
                    where: {
                        productId: production.productId,
                    },
                });
            } else if (production.fabricatingMaterialId != null){
                var originalMaterial = await FabricatingMaterial.findOne({
                    where: {
                        fabricatingMaterialId: production.fabricatingMaterialId,
                    },
                }, {
                    subQuery: false,
                });
                FabricatingMaterial.update({
                    fabricatingMaterialQty: String(
                        parseInt(originalMaterial.fabricatingMaterialQty) - parseInt(production.productionQty)
                    ),
                }, {
                    where: {
                        fabricatingMaterialId: production.fabricatingMaterialId,
                    },
                });
            }
        }

        Production.destroy({
            where: {
                productionCode: _productionCode,
            },
        })
        return res.json({
            message: "Berhasil produksi dihapus!",
            status: "success",
        });


    } catch (error) {
        
    }
}