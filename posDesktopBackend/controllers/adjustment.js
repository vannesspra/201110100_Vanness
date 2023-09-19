import Product from "../models/productModel.js";
import Type from "../models/typeModel.js";
import Color from "../models/colorModel.js";
import Material from "../models/materialModel.js";
import { Op } from "sequelize";
import Adjustment from "../models/adjustmentModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { createLog } from "../functions/createLog.js";


export const getAdjustments = async (req, res) => {
  try {
    await Adjustment.findAll({
      order: [['adjustmentDate', 'DESC']],
      include: [
        {
          model: Material,
          required: false,
        },
        {
          model: Product,
          required: false,
        },
        {
          model: FabricatingMaterial,
          required: false,
        },
      ],
      
    }).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua penyesuaian berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data penyesuaian",
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

export const getAdjustment = async (req, res) => {
  try {
    var _adjustmentId = parseInt(req.params.adjustmentId);
    await Adjustment.findAll({
      order: [['adjustmentDate', 'DESC']],
      include: [{
        model: Product,
        required: false,
      },
      {
        model: Material,
        required: true,
      },
      {
        model: FabricatingMaterial,
        required: false,
      },
    ],
      
    }, {
      subQuery: false,
    }).then((response) => {
      return res.json({
        message: "Data adjustment berhasil diambil",
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

export const createAdjustment = async (req, res) => {
  try {
    const dateNow = Date.now();
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    if (isNaN(parseInt(req.body.adjustedQty)) && req.body.adjustedQty != null) {
      return res.json({
        message: "Kuantiti harus terdiri dari angka",
        status: "error",
      });
    }

    if (req.body.materialId == null && req.body.productId == null && req.body.fabricatingMaterialId == null){
      return res.json({
        message: "Harus memilih KATEGORI dan ITEM yg ingin disesuaikan",
        status: "error",
      });
    }

    // Get Product or Material
    var _formerQty;
    var _type;
    var _name;
    if(req.body.productId != null){
      await Product.findAll({
        
        where: {
          productId: req.body.productId,
        },
      }, {
        subQuery: false,
      }).then((response) => {
        _formerQty = response[0].productQty;
        _type = "produk"
        _name = response[0].productName;
      });
    } else if(req.body.materialId != null) {
      await Material.findAll({
        
        where: {
          materialId: req.body.materialId,
        },
      }, {
        subQuery: false,
      }).then((response) => {
        _formerQty = response[0].materialQty;
        _type = "bahan baku"
        _name = response[0].materialName;
      });
    } else if(req.body.fabricatingMaterialId != null){
      await FabricatingMaterial.findAll({

        where: {
          fabricatingMaterialId: req.body.fabricatingMaterialId,
        },
      }, {
        subQuery: false,
      }).then((response) => {
        _formerQty = response[0].fabricatingMaterialQty;
        _type = "barang 1/2 jadi"
        _name = response[0].fabricatingMaterialName;
      })
    }

    await Adjustment.create({
      adjustmentCode: req.body.adjustmentCode,
      adjustmentDate: dateNow,
      materialId: req.body.materialId,
      productId: req.body.productId,
      fabricatingMaterialId: req.body.fabricatingMaterialId,
      formerQty: _formerQty,
      adjustedQty: req.body.adjustedQty,
      adjustmentReason: req.body.adjustmentReason,
      adjustmentDesc: req.body.adjustmentDesc,
    }).then(async (response) => {
      if(_type == "produk"){
        await Product.update(
          {
            productQty: req.body.adjustedQty
          }, {
            where: {
              productId: req.body.productId,
            },
          }
        );
      } else if (_type == "bahan baku"){
        await Material.update(
          {
            materialQty: req.body.adjustedQty
          }, {
            where: {
              materialId: req.body.materialId,
            },
          }
        );
      } else if (_type == "barang 1/2 jadi"){
        await FabricatingMaterial.update(
          {
            fabricatingMaterialQty: req.body.adjustedQty
          }, {
            where: {
              fabricatingMaterialId: req.body.fabricatingMaterialId,
            }
          }
        );
      }
      createLog(req.userId, "Penyesuaian", "Penyesuaian Baru")
      return res.json({
        message: "Berhasil membuat penyesuaian pada " + _type + ": " + _name,
        status: "success",
      });
    });
  } catch (error) {
   
    var message = "";
    var field = "";
    console.log(error);

    // Field checking
    // if (error.errors[0].path == "adjustmentCode") {
    //   field = "Kode penyesuaian";
    // } 
    if (error.errors[0].path == "adjustmentDate") {
      field = "Tanggal penyesuaian";
    } else if (error.errors[0].path == "adjustedQty") {
      field = "Penyesuaian kuantiti";
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


