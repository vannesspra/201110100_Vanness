import Customer from "../models/customerModel.js";
import ExtraDiscount from "../models/extraDiscountModel.js";
import { Op } from "sequelize";
import { createLog } from "../functions/createLog.js";

export const getCustomers = async (req, res) => {
  try {
    await Customer.findAll(
      {
        where: {
          isDeleted:{
            [Op.is]: false,
          }
        },
        include: [
          {
            model: ExtraDiscount,
            required: false
          }
        ]
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua customer berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data customer",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createCustomer = async (req, res) => {
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    if(req.body.paymentType == "Kredit"){
      
      if(req.body.paymentTerm == null){
        throw "paymentTerm error";
      }
    }

    var _extraDiscounts = req.body.extraDiscounts
    console.log("SUP "+_extraDiscounts)
    await Customer.create({
      customerCode: req.body.customerCode,
      customerName: req.body.customerName,
      customerAddress: req.body.customerAddress,
      customerPhoneNumber: req.body.customerPhoneNumber,
      customerEmail: req.body.customerEmail,
      customerContactPerson: req.body.customerContactPerson,
      discountOne: req.body.discountOne,
      discountTwo: req.body.discountTwo,
      paymentType: req.body.paymentType,
      paymentTerm: req.body.paymentTerm,
      tax: req.body.tax,
      isDeleted: 0
    }).then((response) => {
      if (_extraDiscounts != null) {
        for (const extraDiscount of _extraDiscounts){
          ExtraDiscount.create(
            {
              customerId: response.customerId,
              amountPaid: extraDiscount.amountPaid,
              discount: extraDiscount.discount
            }
          )
        }
        
      }
      return res.json({
        message: "Data pelanggan berhasil dimasukkan !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    console.log(error)
    if(error == "paymentTerm error"){
      message= "Jangka waktu bayar kredit tidak boleh kosong";
    } else {
      if (error.errors[0].path == "customerCode") {
        field = "Kode pelanggan";
      } else if (error.errors[0].path == "customerName") {
        field = "Nama pelanggan";
      } else if (error.errors[0].path == "customerAddress") {
        field = "Alamat pelanggan";
      } else if (error.errors[0].path == "customerPhoneNumber") {
        field = "Nomor telepon";
      } else if (error.errors[0].path == "customerEmail") {
        field = "Email pelanggan";
      } else if (error.errors[0].path == "customerContactPerson") {
        field = "Kontak person";
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
    }

    
    return res.json({ message: message, status: "error" });
  }
};

export const updateCustomer = async (req, res) => {
  try {
    var _customerId = parseInt(req.query["customerId"]);
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    if(req.body.paymentType == "Kredit"){
      
      if(req.body.paymentTerm == null){
        throw "paymentTerm error";
      }
    }

    var _extraDiscounts = req.body.extraDiscounts
    await Customer.update({
      customerName: req.body.customerName,
      customerAddress: req.body.customerAddress,
      customerPhoneNumber: req.body.customerPhoneNumber,
      customerEmail: req.body.customerEmail,
      customerContactPerson: req.body.customerContactPerson,
      discountOne: req.body.discountOne,
      discountTwo: req.body.discountTwo,
      paymentType: req.body.paymentType,
      paymentTerm: req.body.paymentTerm,
      tax: req.body.tax,
    }, {
      where: {
        customerId: _customerId
      }
    }).then((response) => {
      ExtraDiscount.destroy({
        where: {
          customerId: _customerId,
        },
      });
      if (_extraDiscounts != null) {
        for (const extraDiscount of _extraDiscounts){
          ExtraDiscount.create(
            {
              customerId: _customerId,
              amountPaid: extraDiscount.amountPaid,
              discount: extraDiscount.discount
            }
          )
        }
        
      }
      createLog(req.userId, "Pelanggan", "Edit")
      return res.json({
        message: "Data pelanggan berhasil diubah !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log(error)
    // Field checking
    if(error == "paymentTerm error"){
      message= "Jangka waktu bayar kredit tidak boleh kosong";
    } else {
      if (error.errors[0].path == "customerCode") {
        field = "Kode pelanggan";
      } else if (error.errors[0].path == "customerName") {
        field = "Nama pelanggan";
      } else if (error.errors[0].path == "customerAddress") {
        field = "Alamat pelanggan";
      } else if (error.errors[0].path == "customerPhoneNumber") {
        field = "Nomor telepon";
      } else if (error.errors[0].path == "customerEmail") {
        field = "Email pelanggan";
      } else if (error.errors[0].path == "customerContactPerson") {
        field = "Kontak person";
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
    }
    return res.json({ message: message, status: "error" });
  }
};

export const softDeleteCustomer = async (req, res) => {
  try {
    var _customerId = parseInt(req.query["customerId"]);
    await Customer.update({
      isDeleted: 1
    }, {
      where: {
        customerId: _customerId
      }
    }).then((response) => {
      createLog(req.userId, "Pelanggan", "Delete")
      return res.json({
        message: "Data pelanggan berhasil dihapus !",
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