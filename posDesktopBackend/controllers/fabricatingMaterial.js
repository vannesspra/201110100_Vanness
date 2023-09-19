import { Op } from "sequelize";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { createLog } from "../functions/createLog.js";
import Color from "../models/colorModel.js";
export const getFabricatingMaterials = async(req, res) => {
    try {
        await FabricatingMaterial.findAll({
            include: [
                {
                    model: Color,
                    required: false
                },
            ],
            where: {
                isDeleted: {
                    [Op.is]: false,
                }
            }
        }, {
            subQuery: false,
        }).then((response) => {
            if (response.length > 0) {
                return res.json({
                    message: "Data semua barang setengah jadi berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data barang setengah jadi",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const getFabricatingMaterial = async(req, res) => {
    try {
        var _fabricatingMaterialId = parseInt(req.query["fabricatingMaterialId"]);
        await FabricatingMaterial.findAll({
            where: {
                fabricatingMaterialId: _fabricatingMaterialId,
            },
        }, {
            subQuery: false,
        }).then((response) => {
            return res.json({
                message: "Data barang setengah jadi berhasil diambil",
                status: "success",
                data: response,
            });
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const createFabricatingMaterial = async(req, res) => {
    try {
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }

        if (
            parseInt(req.body.fabricatingMaterialQty) < parseInt(req.body.fabricatingMaterialMinimumStock)
        ) {
            return res.json({
                message: "Kuantiti tidak boleh lebih kecil dari minimal persediaan",
                status: "error",
            });
        }

        await FabricatingMaterial.create({
            fabricatingMaterialCode: req.body.fabricatingMaterialCode,
            fabricatingMaterialName: req.body.fabricatingMaterialName,
            colorId: req.body.colorId,
            fabricatingMaterialUnit: req.body.fabricatingMaterialUnit,
            fabricatingMaterialMinimumStock: req.body.fabricatingMaterialMinimumStock,
            fabricatingMaterialQty: req.body.fabricatingMaterialQty,
            fabricatingMaterialPrice: req.body.fabricatingMaterialPrice,
            isDeleted: 0
        }).then((response) => {
            return res.json({
                message: "Data barang setengah jadi berhasil dimasukkan !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";
        console.log(error)
        // Field checking
        if (error.errors[0].path == "fabricatingMaterialCode") {
            field = "Kode barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialName") {
            field = "Nama barang setengah jadi";
        } else if (error.errors[0].path == "colorId") {
            field = "Warna barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialUnit") {
            field = "Satuan unit barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialMinimumStock") {
            field = "Minimal stock barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialQty") {
            field = "Kuantiti barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialPrice") {
            field = "Harga barang setengah jadi";
        }

        // Set a message
        if (error.errors[0].type == "unique violation") {
            message = field + " " + error.errors[0].value + " sudah terpakai";
        } else if (error.errors[0].type == "notNull Violation") {
            message = field + " tidak boleh kosong";
        }
        return res.json({ message: message, status: "error" });
    }
};

// export const updateProduct = async(req, res) => {
//     try {
//         var _productId = parseInt(req.params.productId);
//         var _colors = req.body.colors;

//         if (
//             req.body.productCode == "" ||
//             req.body.productName == "" ||
//             req.body.typeId == "" ||
//             req.body.productUnit == "" ||
//             req.body.productPrice == "" ||
//             req.body.productDesc == "" ||
//             req.body.productMinimumStock == "" ||
//             req.body.productQty == ""
//         ) {
//             for (var [key, value] of Object.entries(req.body)) {
//                 if (req.body[key] == "") {
//                     req.body[key] = null;
//                 }
//             }
//         }

//         if (
//             isNaN(parseInt(req.body.productPrice)) &&
//             req.body.productPrice != null
//         ) {
//             return res.json({
//                 message: "Harga barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (
//             isNaN(parseInt(req.body.productMinimumStock)) &&
//             req.body.productPrice != null
//         ) {
//             return res.json({
//                 message: "Minimal persediaan barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (isNaN(parseInt(req.body.productQty)) && req.body.productPrice != null) {
//             return res.json({
//                 message: "Kuantiti barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (
//             parseInt(req.body.productQty) < parseInt(req.body.productMinimumStock)
//         ) {
//             return res.json({
//                 message: "Kuantiti barang tidak boleh lebih kecil dari minimal persediaan",
//                 status: "error",
//             });
//         }

//         if (isNaN(parseInt(req.body.productPrice))) {
//             return res.json({
//                 message: "Harga barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (isNaN(parseInt(req.body.productMinimumStock))) {
//             return res.json({
//                 message: "Minimal persediaan barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (isNaN(parseInt(req.body.productQty))) {
//             return res.json({
//                 message: "Kuantiti barang harus terdiri dari angka",
//                 status: "error",
//             });
//         }
//         if (
//             parseInt(req.body.productQty) < parseInt(req.body.productMinimumStock)
//         ) {
//             return res.json({
//                 message: "Kuantiti barang tidak boleh lebih kecil dari minimal persediaan",
//                 status: "error",
//             });
//         }

//         await Product.update({
//             productCode: req.body.productCode,
//             productName: req.body.productName,
//             typeId: req.body.typeId,
//             productUnit: req.body.productUnit,
//             productPrice: req.body.productPrice,
//             productDesc: req.body.productDesc,
//             productMinimumStock: req.body.productMinimumStock,
//             productQty: req.body.productQty,
//         }, {
//             where: {
//                 productId: _productId,
//             },
//         }).then((response) => {
//             ProductColor.destroy({
//                 where: {
//                     productId: _productId,
//                 },
//             });
//             if (_colors.length != 0) {
//                 _colors.forEach((color) => {
//                     ProductColor.create({
//                         colorId: color,
//                         productId: _productId,
//                     });
//                 });
//             }

//             return res.json({
//                 message: "Data produk berhasil dimasukkan !",
//                 status: "success",
//             });
//         });
//     } catch (error) {
//         var message = "";
//         var field = "";

//         // Field checking
//         if (error.errors[0].path == "productCode") {
//             field = "Kode produk";
//         } else if (error.errors[0].path == "productName") {
//             field = "Nama produk";
//         } else if (error.errors[0].path == "typeId") {
//             field = "Tipe produk";
//         } else if (error.errors[0].path == "productUnit") {
//             field = "Satuan unit produk";
//         } else if (error.errors[0].path == "productPrice") {
//             field = "Harga produk";
//         } else if (error.errors[0].path == "productDesc") {
//             field = "Deskripsi produk";
//         } else if (error.errors[0].path == "productMinimumStock") {
//             field = "Minimal stock produk";
//         } else if (error.errors[0].path == "productQty") {
//             field = "Kuantiti produk";
//         }

//         // Set a message
//         if (error.errors[0].type == "unique violation") {
//             message = field + " " + error.errors[0].value + " sudah terpakai";
//         } else if (error.errors[0].type == "notNull Violation") {
//             message = field + " tidak boleh kosong";
//         }
//         return res.json({ message: message, status: "error" });
//     }
// };

export const updateFabricatingMaterial = async(req, res) => {
    try {
        var _fabricatingMaterialId = parseInt(req.query["fabricatingMaterialId"]);
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }
        await FabricatingMaterial.update({
            fabricatingMaterialName: req.body.fabricatingMaterialName,
            colorId: req.body.colorId,
            fabricatingMaterialUnit: req.body.fabricatingMaterialUnit,
            fabricatingMaterialMinimumStock: req.body.fabricatingMaterialMinimumStock,
            fabricatingMaterialQty: req.body.fabricatingMaterialQty,
            fabricatingMaterialPrice: req.body.fabricatingMaterialPrice,
        }, {
            where: {
                fabricatingMaterialId: _fabricatingMaterialId
            }
        }).then((response) => {
            createLog(req.userId, "Barang 1/2 Jadi", "Edit")
            return res.json({
                message: "Data barang setengah jadi berhasil diubah !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "fabricatingMaterialCode") {
            field = "Kode barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialName") {
            field = "Nama barang setengah jadi";
        } else if (error.errors[0].path == "colorId") {
            field = "Warna barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialUnit") {
            field = "Satuan unit barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialMinimumStock") {
            field = "Minimal stock barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialQty") {
            field = "Kuantiti barang setengah jadi";
        } else if (error.errors[0].path == "fabricatingMaterialPrice") {
            field = "Harga barang setengah jadi";
        }

        // Set a message
        if (error.errors[0].type == "unique violation") {
            message = field + " " + error.errors[0].value + " sudah terpakai";
        } else if (error.errors[0].type == "notNull Violation") {
            message = field + " tidak boleh kosong";
        }
        return res.json({ message: message, status: "error" });
    }
};

export const softDeleteFabricatingMaterial = async(req, res) => {
    try {
        var _fabricatingMaterialId = parseInt(req.query["fabricatingMaterialId"]);
        await FabricatingMaterial.update({
            isDeleted: 1
        }, {
            where: {
                fabricatingMaterialId: _fabricatingMaterialId
            }
        }).then((response) => {
            createLog(req.userId, "Barang 1/2 Jadi", "Delete")
            return res.json({
                message: "Data barang setengah jadi berhasil dihapus !",
                status: "success",
            });
        });
    } catch (error) {
        return res.json({
            message: error.message,
            status: "error",
        });
    }
}