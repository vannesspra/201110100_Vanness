import Product from "../models/productModel.js";
// import ProductColor from "../models/productColorModel.js";
import Type from "../models/typeModel.js";
import Color from "../models/colorModel.js";
import { Op } from "sequelize";
import { createLog } from "../functions/createLog.js";

export const getProducts = async (req, res) => {
  try {
    await Product.findAll({
      include: [
        // {
        //   model: ProductColor,
        //   required: false,
        //   include: [{
        //     model: Color,
        //     required: false,
        //   }, ],
        // },
        {
          model: Color,
          required: true
        },
        {
          model: Type,
          required: true,
        },
      ],
      where: {
        isDeleted:{
          [Op.is]: false,
        }
      }
    }, {
      subQuery: false,
    }).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua produk berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data produk",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({
      message: error.message,
      status: "error",
      data: []
    });
  }
};

export const getProduct = async (req, res) => {
  try {
    var _productId = parseInt(req.params.productId);
    await Product.findAll({
      // include: [
      //   {
      //   model: ProductColor,
      //   required: false,
      // }, ],
      where: {
        productId: _productId,
      },
    }, {
      subQuery: false,
    }).then((response) => {
      return res.json({
        message: "Data produk berhasil diambil",
        status: "success",
        data: response,
      });
    });
  } catch (error) {
    return res.json({
      message: error.message,
      status: "error",
      data: []
    });
  }
};

export const createProduct = async (req, res) => {
  try {
    // var _colors = req.body.colors;
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
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

    await Product.create({
      productCode: req.body.productCode,
      productName: req.body.productName,
      typeId: req.body.typeId,
      colorId: req.body.colorId,
      productPrice: req.body.productPrice,
      productDesc: req.body.productDesc,
      productMinimumStock: req.body.productMinimumStock,
      productQty: req.body.productQty,
      isDeleted: 0
    }).then((response) => {
      // if (_colors.length != 0) {
      //   _colors.forEach((color) => {
      //     ProductColor.create({
      //       colorId: color,
      //       productId: response.productId,
      //     });
      //   });
      // }
      return res.json({
        message: "Data produk berhasil dimasukkan !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log(error);

    // Field checking
    if (error.errors[0].path == "productCode") {
      field = "Kode produk";
    } else if (error.errors[0].path == "productName") {
      field = "Nama produk";
    } else if (error.errors[0].path == "typeId") {
      field = "Tipe produk";
    } else if (error.errors[0].path == "colorId") {
      field = "Warna produk";
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
    return res.json({
      message: message,
      status: "error"
    });
  }
};

export const updateProduct = async (req, res) => {
  try {
    var _productId = parseInt(req.query["productId"]);
    // var _colors = req.body.colors;

    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
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
      productName: req.body.productName,
      typeId: req.body.typeId,
      colorId: req.body.colorId,
      productPrice: req.body.productPrice,
      productDesc: req.body.productDesc,
      productMinimumStock: req.body.productMinimumStock,
      productQty: req.body.productQty,
    }, {
      where: {
        productId: _productId,
      },
    }).then((response) => {
      // ProductColor.destroy({
      //   where: {
      //     productId: _productId,
      //   },
      // });
      // if (_colors.length != 0) {
      //   _colors.forEach((color) => {
      //     ProductColor.create({
      //       colorId: color,
      //       productId: _productId,
      //     });
      //   });
      // }
      createLog(req.userId, "Product", "Edit")
      return res.json({
        message: "Data produk berhasil diubah !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log(error)
    // Field checking
    if (error.errors[0].path == "productCode") {
      field = "Kode produk";
    } else if (error.errors[0].path == "productName") {
      field = "Nama produk";
    } else if (error.errors[0].path == "typeId") {
      field = "Tipe produk";
    } else if (error.errors[0].path == "colorId") {
      field = "Warna produk";
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
    return res.json({
      message: message,
      status: "error"
    });
  }
};

export const softDeletedProduct = async (req, res) => {
  try {
    var _productId = parseInt(req.query["productId"]);
    console.log(_productId);

    await Product.update({
      isDeleted: 1
    }, {
      where: {
        productId: _productId,
      },
    }).then((response) => {
    
      createLog(req.userId, "Product", "Delete")
      return res.json({
        message: "Data produk dihapus !",
        status: "success",
      });
    });
  } catch (error) {
    return res.json({
      message: error.message,
      status: "error",
    });
  }
};
