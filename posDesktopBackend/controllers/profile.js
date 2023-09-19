import Profile from "../models/profileModel.js";
import { createLog } from "../functions/createLog.js";

export const getProfile = async (req, res) => {
  try {
    await Profile.findOne({
      where: {
        companyId: 1,
      },
    }).then((response) => {
      if(response != null){
        return res.json({
          message: "Data profile berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Data profile berhasil diambil",
          status: "success",
          data: null,
        });
      }
      
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createProfile = async (req, res) => {
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Profile.create(
      {
        companyName: req.body.companyName,
        companyAddress: req.body.companyAddress,
        companyPhoneNumber: req.body.companyPhoneNumber,
        companyWebsite: req.body.companyWebsite,
        companyEmail: req.body.companyEmail,
        companyContactPerson: req.body.companyContactPerson,
        companyContactPersonNumber: req.body.companyContactPersonNumber,
      },
      {
        
      }
    ).then((response) => {
      return res.json({
        message: "Profil perusahaan berhasil dibuat",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "companyName") {
      field = "Nama perusahaan";
    } else if (error.errors[0].path == "companyPhoneNumber") {
      field = "Nomor handphone perusahaan";
    } else if (error.errors[0].path == "companyWebsite") {
      field = "Website perusahaan";
    } else if (error.errors[0].path == "companyEmail") {
      field = "Email perusahaan";
    } else if (error.errors[0].path == "companyContactPerson") {
      field = "Kontak person";
    } else if (error.errors[0].path == "companyContactPersonNumber") {
      field = "Nomor kontak person";
    } else if (error.errors[0].path == "companyAddress") {
      field = "Alamat perusahaan";
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

export const updateProfile = async (req, res) => {
  try {
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }
    await Profile.update(
      {
        companyName: req.body.companyName,
        companyAddress: req.body.companyAddress,
        companyPhoneNumber: req.body.companyPhoneNumber,
        companyWebsite: req.body.companyWebsite,
        companyEmail: req.body.companyEmail,
        companyContactPerson: req.body.companyContactPerson,
        companyContactPersonNumber: req.body.companyContactPersonNumber,
      },
      {
        where: {
          companyId: 1,
        },
      }
    ).then((response) => {
      createLog(req.userId, "Profile", "Edit")
      return res.json({
        message: "Profil perusahaan berhasil diubah",
        status: "success",
      });
    });
  } catch (error) {
    var message = "";
    var field = "";

    // Field checking
    if (error.errors[0].path == "companyName") {
      field = "Nama perusahaan";
    } else if (error.errors[0].path == "companyPhoneNumber") {
      field = "Nomor handphone perusahaan";
    } else if (error.errors[0].path == "companyWebsite") {
      field = "Website perusahaan";
    } else if (error.errors[0].path == "companyEmail") {
      field = "Email perusahaan";
    } else if (error.errors[0].path == "companyContactPerson") {
      field = "Kontak person";
    } else if (error.errors[0].path == "companyContactPersonNumber") {
      field = "Nomor kontak person";
    } else if (error.errors[0].path == "companyAddress") {
      field = "Alamat perusahaan";
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
