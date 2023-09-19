import MaterialPurchase from "../models/materialPurchaseModel.js";
import Supplier from "../models/supplierModel.js";
import Material from "../models/materialModel.js";

import MaterialSpending from "../models/materialSpendingModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { where } from "sequelize";
import { createLog } from "../functions/createLog.js";

export const getMaterialSpendingByCode = async (req, res) => {
  var _materialSpendingCode = req.query["materialSpendingCode"];
  try {
    await MaterialSpending.findAll(
      {
        order: [['materialSpendingDate', 'DESC']],
        include: [
          {
            model: Material,
            required: false,
          },
          {
            model: FabricatingMaterial,
            required: false,
          }
        ],
        where: {
          materialSpendingCode: _materialSpendingCode,
        },
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pengeluaran bahan baku berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pengeluaran bahan baku",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getMaterialSpendingsGrouped = async (req, res) => {
  try {
    await MaterialSpending.findAll(
      {
        order: [['materialSpendingDate', 'DESC']],
        include: [
          {
            model: Material,
            required: false,
          },
          {
            model: FabricatingMaterial,
            required: false,
          },
        ],
        group: "materialSpendingCode",
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pengeluaran bahan baku berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pengeluaran bahan baku",
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

export const getMaterialSpendings = async (req, res) => {
  try {
    await MaterialSpending.findAll(
      {
        order: [['materialSpendingDate', 'DESC']],
        include: [
          {
            model: Material,
            required: false,
          },
          {
            model: FabricatingMaterial,
            required: false,
          },
        ],
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pengeluaran bahan baku berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pengeluaran bahan baku",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createMaterialSpending = async (req, res) => {
  try {
    const dateNow = Date.now();
    var _materials = req.body.materials;
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    // if (isNaN(parseInt(req.body.qty)) && req.body.qty != null) {
    //   return res.json({
    //     message: "Kuantiti harus terdiri dari angka",
    //     status: "error",
    //   });
    // }

    // if (_materials.length != 0) {
    //   for (const material of _materials) {
        
    //     var originalMaterial = await Material.findOne(
    //       {
    //         where: {
    //           materialId: material.id,
    //         },
    //       },
    //       {
    //         subQuery: false,
    //       }
    //     );
    //     if (originalMaterial.materialQty == "0") {
    //       throw "error empty qty";
    //     } else if (parseInt(material.qty) > parseInt(originalMaterial.materialQty)) {
          
    //       throw "error insufficient qty";
    //     }
    //   }

    //   for (const material of _materials) {
    //     await MaterialSpending.create({
    //       materialSpendingCode: req.body.materialSpendingCode,
    //       materialSpendingDate: dateNow,
    //       materialSpendingQty: material.qty,
    //       materialId: parseInt(material.id),
    //     }).then(async (_) => {
    //       var originalMaterial = await Material.findOne(
    //         {
    //           where: {
    //             materialId: material.id,
    //           },
    //         },
    //         {
    //           subQuery: false,
    //         }
    //       );
    //       Material.update(
    //         {
    //           materialQty: String(
    //             parseInt(originalMaterial.materialQty) - parseInt(material.qty)
    //           ),
    //         },
    //         {
    //           where: {
    //             materialId: material.id,
    //           },
    //         }
    //       );
    //     });
    //   }
    //   return res.json({
    //     message: "Berhasil membuat pemasukkan bahan baku !",
    //     status: "success",
    //   });
    
    if (_materials.length != 0) {
      for (const material of _materials) {
        console.log(material.FabricatingMaterialId)
        console.log(material.materialId)
        await MaterialSpending.create({
          materialSpendingCode: req.body.materialSpendingCode,
          materialSpendingDate: req.body.materialSpendingDate,
          materialSpendingQty: material.qty,
          materialId: material.materialId,
          fabricatingMaterialId: material.fabricatingMaterialId,
        }).then(async (_) => {
          if(material.materialId != null) {
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
                  parseInt(originalMaterial.materialQty) - parseInt(material.qty)
                ),
              },
              {
                where: {
                  materialId: material.materialId,
                },
              }
            );
          }
          if(material.fabricatingMaterialId != null) {
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
                  parseInt(originalMaterial.fabricatingMaterialQty) - parseInt(material.qty)
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
      createLog(req.userId, "Pengeluaran", "Pengeluaran Baru")
      return res.json({
        message: "Berhasil membuat pemasukkan!",
        status: "success",
      });
    } else {
      throw "error materials";
    }
  } catch (error) {
    var message = "";
    var field = ""
    console.log(error)
    if (error == "error materials") {
      return res.json({
        message: "Masukkan setidaknya 1 bahan baku",
        status: "error",
      });
    } else {
      // Field checking
      if (error.errors[0].path == "materialSpendingCode") {
        field = "Kode pengeluaran bahan baku";
      } else if (error.errors[0].path == "materialSpendingDate") {
        field = "Tanggal pengeluaran bahan baku";
      } else if (error.errors[0].path == "materialSpendingQty") {
        field = "Kuantiti pengeluaran bahan baku";
      }

      // Set a message
      if (error.errors[0].type == "unique violation") {
        message = field + " " + error.errors[0].value + " sudah terpakai";
      } else if (error.errors[0].type == "notNull Violation") {
        message = field + " tidak boleh kosong";
      }
      return res.json({message: message, status: "errror"});
    }
  }
  // catch (error) {
  //   var message = "";
  //   var field = "";
  //   if (error == "error materials") {
  //     return res.json({
  //       message: "Masukkan setidaknya 1 bahan baku",
  //       status: "error",
  //     });
  //   } else if (error == "error insufficient qty") {
  //     return res.json({
  //       message:
  //         "Tidak bisa melanjutkan proses pengeluaran dikarenakan bahan baku tidak mencukupi",
  //       status: "error",
  //     });
  //   } else if (error == "error empty qty") {
  //     return res.json({
  //       message:
  //         "Tidak bisa melanjutkan proses pengeluaran dikarenakan bahan baku habis",
  //       status: "error",
  //     });
  //   } else {
  //     // Field checking
  //     if (error.errors[0].path == "materialSpendingCode") {
  //       field = "Kode pengeluaran bahan baku";
  //     } else if (error.errors[0].path == "materialSpendingQty") {
  //       field = "Kuantiti pengeluaran bahan baku";
  //     }

  //     // Set a message
  //     if (error.errors[0].type == "unique violation") {
  //       message = field + " " + error.errors[0].value + " sudah terpakai";
  //     } else if (error.errors[0].type == "notNull Violation") {
  //       message = field + " tidak boleh kosong";
  //     }
  //     return res.json({ message: message, status: "error" });
  //   }
  // }
};

export const deleteSpending = async(req, res) => {
  try {
    var _materialSpendingCode = req.query["materialSpendingCode"];
      var spendings =  await MaterialSpending.findAll(
        {
          order: [['materialSpendingDate', 'DESC']],
          include: [
            {
              model: Material,
              required: false,
            },
            {
              model: FabricatingMaterial,
              required: false,
            }
          ],
          where: {
            materialSpendingCode: _materialSpendingCode,
          },
        },
        {
          subQuery: false,
        }
      )
      for (const spending of spendings){
          console.log("KUSO : " + spending.productId);
          if(spending.materialId != null) {
            var originalMaterial = await Material.findOne(
              {
                where: {
                  materialId: spending.materialId,
                },
              },
              {
                subQuery: false,
              }
            );
            Material.update(
              {
                materialQty: String(
                  parseInt(originalMaterial.materialQty) + parseInt(spending.materialSpendingQty)
                ),
              },
              {
                where: {
                  materialId: spending.materialId,
                },
              }
            );
          }
          if(spending.fabricatingMaterialId != null) {
            var originalMaterial = await FabricatingMaterial.findOne(
              {
                where: { 
                  fabricatingMaterialId: spending.fabricatingMaterialId,
                },
              },
              {
                subQuery: false,
              }
            );
            FabricatingMaterial.update(
              {
                fabricatingMaterialQty: String(
                  parseInt(originalMaterial.fabricatingMaterialQty) + parseInt(spending.materialSpendingQty)
                ),
              },
              {
                where: {
                  fabricatingMaterialId: spending.fabricatingMaterialId,
                },
              }
            );
          }
        
      }

      MaterialSpending.destroy({
          where: {
            materialSpendingCode: _materialSpendingCode,
          },
      })
      return res.json({
          message: "Berhasil produksi dihapus!",
          status: "success",
      });


  } catch (error) {
      
  }
}
