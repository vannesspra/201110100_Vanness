import Material from "../models/materialModel.js";
import { createLog } from "../functions/createLog.js";
import { Op } from "sequelize";
import Color from "../models/colorModel.js";
export const getMaterials = async(req, res) => {
    try {
        await Material.findAll({
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
                    message: "Data semua bahan baku berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data bahan baku",
                    status: "success",
                    data: [],
                });
            }
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const getMaterial = async(req, res) => {
    try {
        var _materialId = parseInt(req.query["materialId"]);
        await Material.findAll({
            where: {
                materialId: _materialId,
            },
        }, {
            subQuery: false,
        }).then((response) => {
            return res.json({
                message: "Data bahan baku berhasil diambil",
                status: "success",
                data: response,
            });
        });
    } catch (error) {
        return res.json({ message: error.message, status: "error", data: [] });
    }
};

export const createMaterial = async(req, res) => {
    try {
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }

        if (
            parseInt(req.body.materialQty) < parseInt(req.body.materialMinimumStock)
        ) {
            return res.json({
                message: "Kuantiti bahan baku tidak boleh lebih kecil dari minimal persediaan",
                status: "error",
            });
        }

        await Material.create({
            materialCode: req.body.materialCode,
            materialName: req.body.materialName,
            colorId: req.body.colorId,
            materialUnit: req.body.materialUnit,
            materialMinimumStock: req.body.materialMinimumStock,
            materialQty: req.body.materialQty,
            materialPrice: req.body.materialPrice,
            isDeleted: 0
        }).then((response) => {
            return res.json({
                message: "Data bahan baku berhasil dimasukkan !",
                status: "success",
            });
        });
    } catch (error) {
        console.log(error)
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "materialCode") {
            field = "Kode bahan baku";
        } else if (error.errors[0].path == "materialName") {
            field = "Nama bahan baku";
        } else if (error.errors[0].path == "colorId") {
            field = "Warna bahan baku";
        } else if (error.errors[0].path == "materialUnit") {
            field = "Satuan unit bahan baku";
        } else if (error.errors[0].path == "materialMinimumStock") {
            field = "Minimal stock bahan baku";
        } else if (error.errors[0].path == "materialQty") {
            field = "Kuantiti bahan baku";
        } else if (error.errors[0].path == "materialPrice") {
            field = "Harga bahan baku";
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

export const updateProduct = async(req, res) => {
    try {
        var _productId = parseInt(req.params.productId);
        var _colors = req.body.colors;

        if (
            req.body.productCode == "" ||
            req.body.productName == "" ||
            req.body.typeId == "" ||
            req.body.productUnit == "" ||
            req.body.productPrice == "" ||
            req.body.productDesc == "" ||
            req.body.productMinimumStock == "" ||
            req.body.productQty == ""
        ) {
            for (var [key, value] of Object.entries(req.body)) {
                if (req.body[key] == "") {
                    req.body[key] = null;
                }
            }
        }

        if (
            isNaN(parseInt(req.body.productPrice)) &&
            req.body.productPrice != null
        ) {
            return res.json({
                message: "Harga barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (
            isNaN(parseInt(req.body.productMinimumStock)) &&
            req.body.productPrice != null
        ) {
            return res.json({
                message: "Minimal persediaan barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (isNaN(parseInt(req.body.productQty)) && req.body.productPrice != null) {
            return res.json({
                message: "Kuantiti barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (
            parseInt(req.body.productQty) < parseInt(req.body.productMinimumStock)
        ) {
            return res.json({
                message: "Kuantiti barang tidak boleh lebih kecil dari minimal persediaan",
                status: "error",
            });
        }

        if (isNaN(parseInt(req.body.productPrice))) {
            return res.json({
                message: "Harga barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (isNaN(parseInt(req.body.productMinimumStock))) {
            return res.json({
                message: "Minimal persediaan barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (isNaN(parseInt(req.body.productQty))) {
            return res.json({
                message: "Kuantiti barang harus terdiri dari angka",
                status: "error",
            });
        }
        if (
            parseInt(req.body.productQty) < parseInt(req.body.productMinimumStock)
        ) {
            return res.json({
                message: "Kuantiti barang tidak boleh lebih kecil dari minimal persediaan",
                status: "error",
            });
        }

        await Product.update({
            productCode: req.body.productCode,
            productName: req.body.productName,
            typeId: req.body.typeId,
            productUnit: req.body.productUnit,
            productPrice: req.body.productPrice,
            productDesc: req.body.productDesc,
            productMinimumStock: req.body.productMinimumStock,
            productQty: req.body.productQty,
        }, {
            where: {
                productId: _productId,
            },
        }).then((response) => {
            ProductColor.destroy({
                where: {
                    productId: _productId,
                },
            });
            if (_colors.length != 0) {
                _colors.forEach((color) => {
                    ProductColor.create({
                        colorId: color,
                        productId: _productId,
                    });
                });
            }

            return res.json({
                message: "Data produk berhasil dimasukkan !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "productCode") {
            field = "Kode produk";
        } else if (error.errors[0].path == "productName") {
            field = "Nama produk";
        } else if (error.errors[0].path == "typeId") {
            field = "Tipe produk";
        } else if (error.errors[0].path == "productUnit") {
            field = "Satuan unit produk";
        } else if (error.errors[0].path == "productPrice") {
            field = "Harga produk";
        } else if (error.errors[0].path == "productDesc") {
            field = "Deskripsi produk";
        } else if (error.errors[0].path == "productMinimumStock") {
            field = "Minimal stock produk";
        } else if (error.errors[0].path == "productQty") {
            field = "Kuantiti produk";
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

export const updateMaterial = async(req, res) => {
    try {
        var _materialId = parseInt(req.query["materialId"]);
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }
        await Material.update({
            materialName: req.body.materialName,
            colorId: req.body.colorId,
            materialUnit: req.body.materialUnit,
            materialMinimumStock: req.body.materialMinimumStock,
            materialQty: req.body.materialQty,
            materialPrice: req.body.materialPrice,
        }, {
            where: {
                materialId: _materialId
            }
        }).then((response) => {
            createLog(req.userId, "Bahan Baku", "Edit")
            return res.json({
                message: "Data Bahan baku berhasil diubah !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "materialCode") {
            field = "Kode bahan baku";
        } else if (error.errors[0].path == "materialName") {
            field = "Nama bahan baku";
        } else if (error.errors[0].path == "colorId") {
            field = "Warna bahan baku";
        } else if (error.errors[0].path == "materialUnit") {
            field = "Satuan unit bahan baku";
        } else if (error.errors[0].path == "materialMinimumStock") {
            field = "Stok minimum bahan baku";
        } else if (error.errors[0].path == "materialQty") {
            field = "Kuantiti bahan baku";
        } else if (error.errors[0].path == "materialPrice") {
            field = "Harga bahan baku";
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

export const softDeleteMaterial = async(req, res) => {
    try {
        var _materialId = parseInt(req.query["materialId"]);
        await Material.update({
            isDeleted: 1
        }, {
            where: {
                materialId: _materialId
            }
        }).then((response) => {
            createLog(req.userId, "Bahan Baku", "Delete")
            return res.json({
                message: "Data Bahan baku berhasil dihapus !",
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