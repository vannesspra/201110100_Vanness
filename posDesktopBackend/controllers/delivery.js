import Delivery from "../models/deliveryModel.js";
import Order from "../models/orderModel.js";
import Product from "../models/productModel.js";
import Customer from "../models/customerModel.js";
import { where } from "sequelize";
import Material from "../models/materialModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import { createLog } from "../functions/createLog.js";

export const getDeliveryOrder = async (req, res) => {
  var _deliveryId = parseInt(req.query["deliveryId"]);
  try {
    await Order.findAll(
      {
        order: [['orderDate', 'DESC']],
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
          deliveryId: _deliveryId,
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

export const getDeliveries = async (req, res) => {
  try {
    await Delivery.findAll(
      {
        order: [['deliveryDate', 'DESC']],
      },
      {
        subQuery: false,
      }
    ).then((response) => {
      if (response.length > 0) {
        return res.json({
          message: "Data semua pengiriman berhasil diambil",
          status: "success",
          data: response,
        });
      } else {
        return res.json({
          message: "Tidak ada data pengiriman",
          status: "success",
          data: [],
        });
      }
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const createDelivery = async (req, res) => {
  try {
    var _orders = req.body.orders;
    const dateNow = Date.now();
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    for (const order of _orders) {
      var orders = await Order.findAll(
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
            orderCode: order,
          },
        },
        {
          subQuery: false,
        }
      );
      orders.forEach((order) => {
        if(order.productId != null){
          if (parseInt(order.product.productQty) - parseInt(order.qty) < 0) {
            throw "qty error";
          }
        } else if (order.materialId != null){
          if (parseInt(order.material.materialQty) - parseInt(order.qty) < 0) {
            throw "qty error";
          }
        } else if (order.fabricatingMaterialId != null){
          if (parseInt(order.fabricatingMaterial.fabricatingMaterialQty) - parseInt(order.qty) < 0) {
            throw "qty error";
          }
        }
      });
    }

    await Delivery.create({
      deliveryCode: req.body.deliveryCode,
      deliveryDate: req.body.deliveryDate,
      carPlatNumber: req.body.carPlatNumber,
      senderName: req.body.senderName,
      deliveryDesc: req.body.deliveryDesc,
    }).then((response) => {
      if (_orders.length != 0) {
        _orders.forEach(async (order) => {
          Order.update(
            {
              deliveryId: response.deliveryId,
              orderStatus: "Sudah dikirim",
            },
            {
              where: {
                orderCode: order,
              },
            }
          ).then(async (value) => {
            var orders = await Order.findAll(
              {
                where: {
                  orderCode: order,
                },
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
                ],
              },
              {
                subQuery: false,
              }
            );

            orders.forEach((element) => {
              console.log("ITER : " + element.productId)
              if(element.productId != null){
                Product.update(
                  {
                    productQty: String(
                      parseInt(element.product.productQty) - parseInt(element.qty)
                    ),
                  },
                  {
                    where: {
                      productId: element.productId,
                    },
                  }
                );
              } else if (element.materialId != null){
                Material.update(
                  {
                    materialQty: String(
                      parseInt(element.material.materialQty) - parseInt(element.qty)
                    ),
                  },
                  {
                    where: {
                      materialId: element.materialId,
                    },
                  }
                );
              } else if (element.fabricatingMaterialId != null){
                FabricatingMaterial.update(
                  {
                    fabricatingMaterialQty: String(
                      parseInt(element.fabricatingMaterial.fabricatingMaterialQty) - parseInt(element.qty)
                    ),
                  },
                  {
                    where: {
                      fabricatingMaterialId: element.fabricatingMaterialId,
                    },
                  }
                );
              }
            });
          });
        });
        createLog(req.userId, "Pengiriman", "Pengiriman Baru")
        return res.json({
          message: "Data pengiriman berhasil dimasukkan !",
          status: "success",
        });
      }
    });
  } catch (error) {
    var message = "";
    var field = "";
    console.log(error);
    // Field checking
    if (error == "qty error") {
      message =
        "Gagal melakukan pengiriman dikarenakan qty barang tidak mencukupi!";
    } else {
      if (error.errors[0].path == "deliveryCode") {
        field = "Kode pengiriman";
      } else if (error.errors[0].path == "carPlatNumber") {
        field = "Nomor plat mobil";
      } else if (error.errors[0].path == "senderName") {
        field = "Nama pengirim";
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
