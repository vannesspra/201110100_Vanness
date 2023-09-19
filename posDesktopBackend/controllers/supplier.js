import Supplier from "../models/supplierModel.js";
import SupplierProduct from "../models/supplierProductModel.js"
import {
    Op
} from "sequelize";

import Product from "../models/productModel.js";
import Material from "../models/materialModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { createLog } from "../functions/createLog.js";
export const getSuppliers = async (req, res) => {
    try {
        await Supplier.findAll({
            include: [
                {
                  model: SupplierProduct,
                  required: false,
                  include: [
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
                  ]
                }
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
                    message: "Data semua supplier berhasil diambil",
                    status: "success",
                    data: response,
                });
            } else {
                return res.json({
                    message: "Tidak ada data supplier",
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

export const createSupplier = async (req, res) => {
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
        
        var _supplierProducts = req.body.supplierProducts
        var _supplierMaterials = req.body.supplierMaterials
        var _supplierFabricatingMaterials = req.body.supplierFabricatingMaterials
        await Supplier.create({
            supplierCode: req.body.supplierCode,
            supplierName: req.body.supplierName,
            supplierAddress: req.body.supplierAddress,
            supplierPhoneNumber: req.body.supplierPhoneNumber,
            supplierEmail: req.body.supplierEmail,
            supplierContactPerson: req.body.supplierContactPerson,
            paymentType: req.body.paymentType,
            supplierTax: req.body.supplierTax,
            paymentTerm: req.body.paymentTerm,
            isDeleted: 0
        }).then((response) => {
            
            if (_supplierProducts != null) {
                for (const supplierProduct of _supplierProducts){
                 if(supplierProduct.productId != null){
                    SupplierProduct.create(
                        {
                          supplierId: response.supplierId,
                          materialId: supplierProduct.materialId,
                          fabricatingMaterialId: supplierProduct.fabricatingMaterialId,
                          productId: supplierProduct.productId,
                        }
                      )
                 }
                }  
                
              }
            
            if (_supplierMaterials != null){
                for (const supplierMaterial of _supplierMaterials){
                    if(supplierMaterial.materialId != null){
                        SupplierProduct.create(
                           {
                             supplierId: response.supplierId,
                             materialId: supplierMaterial.materialId,
                             fabricatingMaterialId: supplierMaterial.fabricatingMaterialId,
                             productId: supplierMaterial.productId,
                           }
                         )
                    }
                   }
            }

            if (_supplierFabricatingMaterials != null){
                for (const supplierFabricatingMaterial of _supplierFabricatingMaterials){
                    if(supplierFabricatingMaterial.fabricatingMaterialId != null){
                       SupplierProduct.create(
                           {
                             supplierId: response.supplierId,
                             materialId: supplierFabricatingMaterial.materialId,
                             fabricatingMaterialId: supplierFabricatingMaterial.fabricatingMaterialId,
                             productId: supplierFabricatingMaterial.productId,
                           }
                         )
                    }
                   }
            }

                
            return res.json({
                message: "Data pemasok berhasil dimasukkan !",
                status: "success",
            });
        });
    }   catch (error) {
        var message = "";
        var field = "";

        // Field checking
        console.log(error)
        if(error == "paymentTerm error")
        {
            message= "Jangka waktu bayar kredit tidak boleh kosong";
        }

        if (error.errors[0].path == "supplierCode") {
            field = "Kode pemasok";
        } else if (error.errors[0].path == "supplierName") {
            field = "Nama pemasok";
        } else if (error.errors[0].path == "supplierAddress") {
            field = "Alamat pemasok";
        } else if (error.errors[0].path == "supplierPhoneNumber") {
            field = "Nomor telepon";
        } else if (error.errors[0].path == "supplierEmail") {
            field = "Email pemasok";
        } else if (error.errors[0].path == "supplierContactPerson") {
            field = "Kontak person";
        } else if (error.errors[0].path == "paymentType") {
            field = "Jenis Pembayaran";
        // } else if (error.errors[0].path == "paymentTerm") {
        //     field = "Tenggat Waktu Pembayaran";
        } else if (error.errors[0].path == "supplierTax") {
            field = "PPN";
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

export const updateSupplier = async (req, res) => {
    try {
        var _supplierId = parseInt(req.query["supplierId"]);
        for (var [key, value] of Object.entries(req.body)) {
            if (req.body[key] == "") {
                req.body[key] = null;
            }
        }
        var _supplierProducts = req.body.supplierProducts
        var _supplierMaterials = req.body.supplierMaterials
        var _supplierFabricatingMaterials = req.body.supplierFabricatingMaterials
        await Supplier.update({
            supplierName: req.body.supplierName,
            supplierAddress: req.body.supplierAddress,
            supplierPhoneNumber: req.body.supplierPhoneNumber,
            supplierEmail: req.body.supplierEmail,
            supplierContactPerson: req.body.supplierContactPerson,
            paymentType: req.body.paymentType,
            supplierTax: req.body.supplierTax,
            paymentTerm: req.body.paymentTerm,
            
        }, {
            where: {
              supplierId: _supplierId
            }
          }).then((response) => {
            SupplierProduct.destroy({
                where: {
                  supplierId: _supplierId,
                },
              });
              if (_supplierProducts != null) {
                for (const supplierProduct of _supplierProducts){
                 if(supplierProduct.productId != null){
                    SupplierProduct.create(
                        {
                          supplierId: _supplierId,
                          materialId: supplierProduct.materialId,
                          fabricatingMaterialId: supplierProduct.fabricatingMaterialId,
                          productId: supplierProduct.productId,
                        }
                      )
                 }
                }  
                
              }
            
            if (_supplierMaterials != null){
                for (const supplierMaterial of _supplierMaterials){
                    if(supplierMaterial.materialId != null){
                        SupplierProduct.create(
                           {
                             supplierId: _supplierId,
                             materialId: supplierMaterial.materialId,
                             fabricatingMaterialId: supplierMaterial.fabricatingMaterialId,
                             productId: supplierMaterial.productId,
                           }
                         )
                    }
                   }
            }

            if (_supplierFabricatingMaterials != null){
                for (const supplierFabricatingMaterial of _supplierFabricatingMaterials){
                    if(supplierFabricatingMaterial.fabricatingMaterialId != null){
                       SupplierProduct.create(
                           {
                             supplierId: _supplierId,
                             materialId: supplierFabricatingMaterial.materialId,
                             fabricatingMaterialId: supplierFabricatingMaterial.fabricatingMaterialId,
                             productId: supplierFabricatingMaterial.productId,
                           }
                         )
                    }
                   }
            }
            createLog(req.userId, "Pemasok", "Edit")
            return res.json({
                message: "Data pemasok berhasil diupdate !",
                status: "success",
            });
        });
    } catch (error) {
        var message = "";
        var field = "";

        // Field checking
        if (error.errors[0].path == "supplierCode") {
            field = "Kode pemasok";
        } else if (error.errors[0].path == "supplierName") {
            field = "Nama pemasok";
        } else if (error.errors[0].path == "supplierAddress") {
            field = "Alamat pemasok";
        } else if (error.errors[0].path == "supplierPhoneNumber") {
            field = "Nomor telepon";
        } else if (error.errors[0].path == "supplierEmail") {
            field = "Email pemasok";
        } else if (error.errors[0].path == "supplierContactPerson") {
            field = "Kontak person";
        } else if (error.errors[0].path == "paymentType") {
            field = "Jenis Pembayaran";
        } else if (error.errors[0].path == "paymentTerm") {
            field = "Tenggat Waktu Pembayaran";
        } else if (error.errors[0].path == "supplierTax") {
            field = "PPn";
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

export const softDeleteSupplier = async (req, res) => {
    try {
      var _supplierId = parseInt(req.query["supplierId"]);
      await Supplier.update({
        isDeleted: 1
      }, {
        where: {
          supplierId: _supplierId
        }
      }).then((response) => {
        createLog(req.userId, "Pemasok", "Delete")
        return res.json({
          message: "Data pemasok berhasil dihapus !",
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