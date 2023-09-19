import Type from "../models/typeModel.js";
import {
  Op
} from "sequelize";
import { createLog } from "../functions/createLog.js";
export const createType = async (req, res) => {
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Type.create({
      typeCode: req.body.typeCode,
      typeName: req.body.typeName,
      typeDesc: req.body.typeDesc,
      isDeleted: 0,
    }).then((response) => {
      return res.json({
        message: "Jenis produk baru berhasil dibuat",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "typeCode") {
      field = "Kode Jenis Produk";
    } else if (error.errors[0].path == "typeName") {
      field = "Jenis Produk";
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

export const getTypes = async (req, res) => {
  try {
    2;
    await Type.findAll({
      where: {
        isDeleted: {
          [Op.is]: false,
        }
      }
    }).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua jenis produk berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data jenis produk",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const updateType = async (req, res) => {
  try {
    var _typeId = parseInt(req.query["typeId"]);
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Type.update({
      typeName: req.body.typeName,
      typeDesc: req.body.typeDesc,
    }, {
      where: {
        typeId: _typeId
      }
    }).then((response) => {
      createLog(req.userId, "Tipe Produk", "Edit")
      return res.json({
        message: "Jenis data produk berhasil diupdate !",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "typeCode") {
      field = "Kode Jenis Produk";
    } else if (error.errors[0].path == "typeName") {
      field = "Jenis Produk";
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

export const softDeleteType = async (req, res) => {
  try {
    var _typeId = parseInt(req.query["typeId"]);
    await Type.update({
      isDeleted: 1
    }, {
      where: {
        typeId: _typeId
      }
    }).then((response) => {
      return res.json({
        message: "Jenis data produk berhasil dihapus !",
        status: "success"
      });
    });
  } catch (error) {
    createLog(req.userId, "Jenis Produk", "Delete")
    return res.json({
      message: error.message,
      status: "error",
    });
  }
};
