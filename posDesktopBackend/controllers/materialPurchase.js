import Order from "../models/orderModel.js";
import Delivery from "../models/deliveryModel.js";
import Product from "../models/productModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";

import MaterialPurchase from "../models/materialPurchaseModel.js";
import Supplier from "../models/supplierModel.js";
import Material from "../models/materialModel.js";
import { where } from "sequelize";
import { createLog } from "../functions/createLog.js";


export const getMaterialPurchaseByCode = async (req, res) => {
  var _materialPurchaseCode = req.query["materialPurchaseCode"];
  try {
    await MaterialPurchase.findAll(
      {
        order: [['materialPurchaseDate', 'DESC']],
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
          {
            model: Supplier,
            required: true,
          },
        ],
        where: {
          materialPurchaseCode: _materialPurchaseCode,
        },
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua PO berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data PO",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getMaterialPurchaseGrouped = async (req, res) => {
  try {
    await MaterialPurchase.findAll(
      {
        order: [['materialPurchaseDate', 'DESC']],
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
          {
            model: Supplier,
            required: true,
          },
        ],
        group: "materialPurchaseCode",
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua PO berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data PO",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

// export const checkMaterialPurchaseValid = async (req, res) => {
//   try {
//     var orders = await Order.findAll(
//       {
//         include: [
//           {
//             model: Delivery,
//             required: false,
//           },
//           {
//             model: Product,
//             required: true,
//           },
//           {
//             model: Customer,
//             required: true,
//           },
//         ],
//         where: {
//           orderCode: req.body.orderCode,
//         },
//       },
//       {
//         subQuery: false,
//       }
//     );
//     orders.forEach((order) => {
//       console.log("TESTING " + order.product.productName);
//       if (parseInt(order.product.productQty) - parseInt(order.qty) < 0) {
//         throw "error";
//       }
//     });
//     // .then((_) => {
//     //   // return res.json({
//     //   //   message: "success",
//     //   //   status: "success",
//     //   //   data: [],
//     //   // });
//     // });
//     return res.json({
//       message: "success",
//       status: "success",
//       data: [],
//     });
//   } catch (error) {
//     return res.json({ message: error.message, status: "error", data: [] });
//   }
// };

export const getMaterialPurchases = async (req, res) => {
  try {
    await MaterialPurchase.findAll(
      {
        order: [['materialPurchaseDate', 'DESC']],
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
          {
            model: Supplier,
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
          message: "Data semua PO berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data PO",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createMaterialPurchase = async (req, res) => {
  try {

    // if (!req.file) {
    //   return res.status(400).send('No file uploaded.');
    // } else {
      
    //   console.log(req.file.path)
    //   return res.status(400).send('File Uploaded.');

    // }

    const dateNow = Date.now();
    console.log(req.body.materials);
    if(req.body.materials == undefined){
      throw "error materials";
    }
    var _materials = JSON.stringify(req.body.materials); // Convert to a string
    _materials = JSON.parse(_materials); 
    
    // for (var [key, value] of Object.entries(req.body)) {
    //   if (req.body[key] == "") {
    //     req.body[key] = null;
    //   }
    // }

    if (req.body.materials.length != 0) {
      for (const material of _materials) {
        console.log(material.supplierId)
        await MaterialPurchase.create({
          materialPurchaseCode: req.body.materialPurchaseCode == "" ? null : req.body.materialPurchaseCode,
          materialPurchaseDate: req.body.materialPurchaseDate,
          materialPurchaseQty: material.qty,
          supplierId: material.supplierId,
          materialId: material.materialId,
          productId: material.productId,
          fabricatingMaterialId: material.fabricatingMaterialId,
          taxAmount: req.body.taxAmount,
          taxInvoiceNumber: req.body.taxInvoiceNumber,
          taxInvoiceImg: !req.file ? null : req.file.path
        }).then(async (_) => {
          if(material.materialId != null){
            var originalMaterial = await Material.findOne(
              {
                where: {
                  materialId: material.materialId,
                },
              },
              {
                subQuery: false,
              }
            );
            Material.update(
              {
                materialQty: String(
                  parseInt(originalMaterial.materialQty) + parseInt(material.qty)
                ),
              },
              {
                where: {
                  materialId: material.materialId,
                },
              }
            );
          }
          if(material.productId != null){
            var originalMaterial = await Product.findOne(
              {
                where: {
                  productId: material.productId,
                },
              },
              {
                subQuery: false,
              }
            );
            Product.update(
              {
                productQty: String(
                  parseInt(originalMaterial.productQty) + parseInt(material.qty)
                ),
              },
              {
                where: {
                  productId: material.productId,
                },
              }
            );
          }
          if(material.fabricatingMaterialId != null){
            var originalMaterial = await FabricatingMaterial.findOne(
              {
                where: {
                  fabricatingMaterialId: material.fabricatingMaterialId,
                },
              },
              {
                subQuery: false,
              }
            );
            FabricatingMaterial.update(
              {
                fabricatingMaterialQty: String(
                  parseInt(originalMaterial.fabricatingMaterialQty) + parseInt(material.qty)
                ),
              },
              {
                where: {
                  fabricatingMaterialId: material.fabricatingMaterialId,
                },
              }
            );
          }
        });
      }
      createLog(req.userId, "Pembelian", "Pembelian Baru")
      return res.json({
        message: "Berhasil membuat PO !",
        status: "success",
      });
    } else {
      throw "error materials";
    }
  } catch (error) {
    var message = "";
    var field = "";
    console.log(error)
    if (error == "error materials") {
      return res.json({
        message: "Masukkan SUPPLIER dan setidak nya 1 BARANG terlebih dahulu",
        status: "error",
      });
    } else {
      // Field checking
      if (error.errors[0].path == "materialPurchaseCode") {
        field = "Kode pembelian";
      } else if (error.errors[0].path == "materialPurchaseDate") {
        field = "Tanggal pembelian";
      } else if (error.errors[0].path == "materialPurchaseQty") {
        field = "Tanggal permintaan pengiriman";
      } else if (error.errors[0].path == "supplierId") {
        field = "Data pemasok";
      }

      // Set a message
      if (error.errors[0].type == "unique violation") {
        message = field + " " + error.errors[0].value + " sudah terpakai";
      } else if (error.errors[0].type == "notNull Violation") {
        message = field + " tidak boleh kosong";
      }
      return res.json({ message: message, status: "error" });
    }
  }
};

export const deletePurchase = async(req, res) => {
  try {
    var _materialPurchaseCode = req.query["materialPurchaseCode"];
      var purchases =  await MaterialPurchase.findAll(
        {
          order: [['materialPurchaseDate', 'DESC']],
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
            {
              model: Supplier,
              required: true,
            },
          ],
          where: {
            materialPurchaseCode: _materialPurchaseCode,
          },
        },
        {
          subQuery: false,
        }
      )
      for (const purchase of purchases){
        if(purchase.materialId != null){
          var originalMaterial = await Material.findOne(
            {
              where: {
                materialId: purchase.materialId,
              },
            },
            {
              subQuery: false,
            }
          );
          Material.update(
            {
              materialQty: String(
                parseInt(originalMaterial.materialQty) - parseInt(purchase.materialPurchaseQty)
              ),
            },
            {
              where: {
                materialId: purchase.materialId,
              },
            }
          );
        }
        if(purchase.productId != null){
          var originalMaterial = await Product.findOne(
            {
              where: {
                productId: purchase.productId,
              },
            },
            {
              subQuery: false,
            }
          );
          Product.update(
            {
              productQty: String(
                parseInt(originalMaterial.productQty) - parseInt(purchase.materialPurchaseQty)
              ),
            },
            {
              where: {
                productId: purchase.productId,
              },
            }
          );
        }
        if(purchase.fabricatingMaterialId != null){
          var originalMaterial = await FabricatingMaterial.findOne(
            {
              where: {
                fabricatingMaterialId: purchase.fabricatingMaterialId,
              },
            },
            {
              subQuery: false,
            }
          );
          FabricatingMaterial.update(
            {
              fabricatingMaterialQty: String(
                parseInt(originalMaterial.fabricatingMaterialQty) - parseInt(purchase.materialPurchaseQty)
              ),
            },
            {
              where: {
                fabricatingMaterialId: purchase.fabricatingMaterialId,
              },
            }
          );
        }
      }

      MaterialPurchase.destroy({
          where: {
            materialPurchaseCode: _materialPurchaseCode,
          },
      })
      return res.json({
          message: "Berhasil produksi dihapus!",
          status: "success",
      });


  } catch (error) {
      
  }
}
