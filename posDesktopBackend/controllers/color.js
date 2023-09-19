import Color from "../models/colorModel.js";
import {
  Op
} from "sequelize";
import { createLog } from "../functions/createLog.js";

export const createColor = async (req, res) => {
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Color.create({
      colorCode: req.body.colorCode,
      colorName: req.body.colorName,
      colorDesc: req.body.colorDesc,
      isDeleted: 0,
    }).then((response) => {
      return res.json({
        message: "Warna baru berhasil dibuat",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "colorCode") {
      field = "Kode warna";
    } else if (error.errors[0].path == "colorName") {
      field = "Warna";
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

export const getColors = async (req, res) => {
  try {
    await Color.findAll({
      where: {
        isDeleted: {
          [Op.is]: false,
        }
      }
    }).then((response) => {
      return res.json({
        message: "Data warna berhasil diambil",
        status: "success",
        data: response,
      });
    });
  } catch (error) {
    return res.json({
      message: "Terjadi kesalahan mengambil data warna",
      status: "error",
      data: [],
      detail: error.message,
    });
  }
};

export const updateColor = async (req, res) => {
  try {
    var _colorId = parseInt(req.query["colorId"]);
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Color.update({
      colorName: req.body.colorName,
      colorDesc: req.body.colorDesc,
    }, {
      where: {
        colorId: _colorId
      }
    }).then((response) => {
      createLog(req.userId, "Warna", "Edit")
      return res.json({
        message: "Warna data produk berhasil diupdate !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "colorCode") {
      field = "Kode warna";
    } else if (error.errors[0].path == "colorName") {
      field = "Warna";
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

export const softDeleteColor = async (req, res) => {
  try {
    var _colorId = parseInt(req.query["colorId"]);
    await Color.update({
      isDeleted: 1
    }, {
      where: {
        colorId: _colorId
      }
    }).then((response) => {
      createLog(req.userId, "Warna", "Delete")
      return res.json({
        message: "Warna data produk berhasil dihapus !",
        status: "success"
      });
    });
  } catch (error) {
    return res.json({
      message: error.message,
      status: "error",
    });
  }
};
