import Product from "../models/productModel.js";
import Customer from "../models/customerModel.js";
import Sale from "../models/invoiceModel.js";
import Order from "../models/orderModel.js";
import Delivery from "../models/deliveryModel.js";
import { Op } from "sequelize";
import Payment from "../models/paymentModel.js";
import Material from "../models/materialModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { createLog } from "../functions/createLog.js";
export const getSaleAvailOrder = async (req, res) => {
  try {
    await Order.findAll(
      {
        include: [
          {
            model: Delivery,
            required: false,
          },
          {
            model: Product,
            required: false,
          },
          {
            model: Material,
            required: false,
          },
          {
            model: FabricatingMaterial,
            required: false,
          },
          {
            model: Customer,
            required: true,
          },
        ],
        where: {
          deliveryId: {
            [Op.not]: null,
          },
          saleId: {
            [Op.is]: null,
          },
        },
        group: "orderCode",
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pesanan berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pesanan",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getSaleOrders = async (req, res) => {
  var _saleId = parseInt(req.query["saleId"]);
  try {
    await Order.findAll(
      {
        include: [
          {
            model: Delivery,
            required: false,
          },
          {
            model: Product,
            required: false,
          },
          {
            model: Material,
            required: false,
          },

          {
            model: FabricatingMaterial,
            required: false,
          },
          {
            model: Customer,
            required: true,
          },
        ],
        where: {
          saleId: _saleId,
        },
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pesanan berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pesanan",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getSaleOrder = async (req, res) => {
  var _saleId = parseInt(req.query["saleId"]);
  try {
    await Order.findAll(
      {
        include: [
          {
            model: Delivery,
            required: false,
          },
          {
            model: Product,
            required: false,
          },
          {
            model: Material,
            required: false,
          },
          {
            model: FabricatingMaterial,
            required: false,
          },
          {
            model: Customer,
            required: true,
          },
        ],
        where: {
          saleId: _saleId,
        },
        group: "orderCode",
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pesanan berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pesanan",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getSales = async (req, res) => {
  try {
    await Sale.findAll(
      {
        include: [
          {
            model: Payment,
            required: false
          },
        ],
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua penjualan berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data penjualan",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createSale = async (req, res) => {
  const dateNow = Date.now();
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }


    if (req.body.orderCode == null) {
      return res.json({
        message: "Pesanan tidak boleh kosong !",
        status: "error",
      });
    }

    await Sale.create({
      saleCode: req.body.saleCode,
      saleDate: req.body.saleDate,
      saleDeadline: req.body.saleDeadline,
      paymentType: req.body.paymentType,
      paymentTerm: req.body.paymentTerm,
      discountOnePercentage: req.body.discountOnePercentage,
      discountTwoPercentage: req.body.discountTwoPercentage,
      extraDiscountPercentage: req.body.extraDiscountPercentage,
      tax: req.body.tax,
      saleDesc: req.body.saleDesc,
      saleStatus: "Belum dibayar",
    }).then((response) => {
      Order.update(
        {
          saleId: response.saleId,
        },
        {
          where: {
            orderCode: req.body.orderCode,
          },
        }
      );
      createLog(req.userId, "Penjualan", "Penjualan Baru")
      return res.json({
        message: "Penjualan berhasil dibuat !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log("TEST "+error)
    // Field checking
    if (error.errors[0].path == "saleCode") {
      field = "Kode penjualan";
    } else if (error.errors[0].path == "orderId") {
      field = "Pesanan";
    } else if (error.errors[0].path == "saleDeadline") {
      field = "Tenggat waktu pembayaran";
    } else if (error.errors[0].path == "saleDate") {
      field = "Tanggal";
    } else if (error.errors[0].path == "productUnit") {
      field = "Satuan unit produk";
    } else if (error.errors[0].path == "paymentType") {
      field = "Tipe pembayaran";
    } else if (error.errors[0].path == "tax") {
      field = "PPN";
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

export const updateSale = async (req, res) => {
  const dateNow = Date.now();
  try {
    var _saleId = parseInt(req.query["saleId"]);
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }


    if (req.body.orderCode == null) {
      return res.json({
        message: "Pesanan tidak boleh kosong !",
        status: "error",
      });
    }

    await Sale.update({
      saleCode: req.body.saleCode,
      saleDate: req.body.saleDate,
      saleDeadline: req.body.saleDeadline,
      paymentType: req.body.paymentType,
      paymentTerm: req.body.paymentTerm,
      discountOnePercentage: req.body.discountOnePercentage,
      discountTwoPercentage: req.body.discountTwoPercentage,
      extraDiscountPercentage: req.body.extraDiscountPercentage,
      tax: req.body.tax,
      saleDesc: req.body.saleDesc,
      saleStatus: "Belum dibayar",
    }, {
      where: {
        saleId: _saleId
      }
    }).then((response) => {
      Order.update(
        {
          saleId: response.saleId,
        },
        {
          where: {
            orderCode: req.body.orderCode,
          },
        }
      );
      createLog(req.userId, "Penjualan", "Penjualan Baru")
      return res.json({
        message: "Penjualan berhasil dibuat !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log("TEST "+error)
    // Field checking
    if (error.errors[0].path == "saleCode") {
      field = "Kode penjualan";
    } else if (error.errors[0].path == "orderId") {
      field = "Pesanan";
    } else if (error.errors[0].path == "saleDeadline") {
      field = "Tenggat waktu pembayaran";
    } else if (error.errors[0].path == "saleDate") {
      field = "Tanggal";
    } else if (error.errors[0].path == "productUnit") {
      field = "Satuan unit produk";
    } else if (error.errors[0].path == "paymentType") {
      field = "Tipe pembayaran";
    } else if (error.errors[0].path == "tax") {
      field = "PPN";
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
