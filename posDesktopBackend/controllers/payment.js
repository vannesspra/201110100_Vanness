import Sale from "../models/invoiceModel.js";
import Payment from "../models/paymentModel.js";
import { createLog } from "../functions/createLog.js";
export const getPaymentById = async (req, res) => {
  var _paymentId = req.query["paymentId"];
  try {
    await Payment.findAll(
      {
        order: [['paymentDate', 'DESC']],
        include: [
          {
            model: Sale,
            required: true,
            
          },
        ],
        where: {
          paymentId: _paymentId,
        },
      },

      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pembayaran berhasil diambil",
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

export const getPayments = async (req, res) => {
  try {
    await Payment.findAll(
      {
        order: [['paymentDate', 'DESC']],
        include: [
          {
            model: Sale,
            required: true,
          },
        ],
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pembayaran berhasil diambil",
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

export const createPayment = async (req, res) => {
  const dateNow = Date.now();
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    await Payment.create({
      paymentCode: req.body.paymentCode,
      paymentDate: req.body.paymentDate,
      paymentDesc: req.body.paymentDesc,
      saleId: req.body.saleId,
    }).then((response) => {
      Sale.update(
        {
          saleStatus: "Sudah dibayar",
        },
        {
          where: {
            saleId: response.saleId,
          },
        }
      );
      createLog(req.userId, "Pembayaran", "Pembayaran Baru")
      return res.json({
        message: "Berhasil melakukan pembayaran !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "paymentCode") {
      field = "Kode pembayaran";
    } else if (error.errors[0].path == "paymentDate") {
      field = "Tanggal pembayaran";
    } else if (error.errors[0].path == "saleId") {
      field = "Penjualan";
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
