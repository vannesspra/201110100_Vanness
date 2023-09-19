import Order from "../models/orderModel.js";
import Delivery from "../models/deliveryModel.js";
import Product from "../models/productModel.js";
import Material from "../models/materialModel.js";
import FabricatingMaterial from "../models/fabricatingMaterialModel.js";
import Customer from "../models/customerModel.js";
import ExtraDiscount from "../models/extraDiscountModel.js";
import { createLog } from "../functions/createLog.js";
export const getOrderById = async (req, res) => {
  var _orderCode = req.query["orderCode"];
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
            include: [
              {
                model: ExtraDiscount,
                required: false
              }
            ]
          },
        ],
        where: {
          orderCode: _orderCode,
        },
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

export const getOrderGrouped = async (req, res) => {
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

export const checkOrderValid = async (req, res) => {
  try {
    var orders = await Order.findAll(
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
          orderCode: req.body.orderCode,
        },
      },
      {
        subQuery: false,
      }
    );
    orders.forEach((order) => {
      if(order.product != null){
        if (parseInt(order.product.productQty) - parseInt(order.qty) < 0) {
          throw "error";
        }
      } else if(order.material != null){
        if (parseInt(order.material.materialQty) - parseInt(order.qty) < 0) {
          throw "error";
        }
      } else if(order.fabricatingMaterial != null){
        if (parseInt(order.fabricatingMaterial.fabricatingMaterialQty) - parseInt(order.qty) < 0) {
          throw "error";
        }
      }
      
    });
    // .then((_) => {
    //   // return res.json({
    //   //   message: "success",
    //   //   status: "success",
    //   //   data: [],
    //   // });
    // });
    return res.json({
      message: "success",
      status: "success",
      data: [],
    });
  } catch (error) {
    return res.json({ message: error.message, status: "error", data: [] });
  }
};

export const getOrders = async (req, res) => {
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

export const createOrder = async (req, res) => {
  try {
    const dateNow = Date.now();
    var _products = req.body.products;
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    if (isNaN(parseInt(req.body.qty)) && req.body.qty != null) {
      return res.json({
        message: "Kuantiti harus terdiri dari angka",
        status: "error",
      });
    }

    else if (req.body.customerId == null) {
      return res.json({
        message: "Pelanggan harus diisi",
        status: "error",
      });
    }
    
    await Order.findAll({
      where: {
        orderCode: req.body.orderCode,
      },
    }).then(result => {
      if(result.length != 0){
        throw "already exist"
      }
    });

    if (_products.length != 0) {
      
      for (const product of _products) {
        
        await Order.create({
          orderCode: req.body.orderCode,
          orderDate: req.body.orderDate,
          requestedDeliveryDate: req.body.requestedDeliveryDate,
          qty: product.qty,
          productId: product.productId,
          materialId: product.materialId,
          fabricatingMaterialId: product.fabricatingMaterialId,
          name: product.name,
          price: product.price,
          customerId: req.body.customerId,
          orderDesc: req.body.orderDesc,
          orderStatus: "Belum dikirim",
        });
      }
      createLog(req.userId, "Sales Order", "Sales Order Baru")
      return res.json({
        message: "Pesanan berhasil dibuat !",
        status: "success",
      });
    } else {
      throw "error products";
    }
  } catch (error) {
    var message = "";
    var field = "";

    console.log("super: "+error);
    if (error == "error products") {
      return res.json({
        message: "Masukkan setidaknya 1 produk",
        status: "error",
      });
    } else if (error == "already exist") {
      return res.json({
        message: "Kode pemesanan telah dipakai !",
        status: "error",
      });
    } else {
      // Field checking
      
      if (error.errors[0].path == "orderCode") {
        field = "Kode pesanan";
      } else if (error.errors[0].path == "orderDate") {
        field = "Tanggal pesanan";
      } else if (error.errors[0].path == "requestedDeliveryDate") {
        field = "Tanggal permintaan pengiriman";
      } else if (error.errors[0].path == "productId") {
        field = "Product";
      } else if (error.errors[0].path == "customerId") {
        field = "Pelanggan";
      } else if (error.errors[0].path == "qty") {
        field = "Kuantiti produk";
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

export const updateOrder = async (req, res) => {
  try {
    var _orderCode = req.query["orderCode"];
    console.log(_orderCode)
    const dateNow = Date.now();
    var _products = req.body.products;
    for (var [key, value] of Object.entries(req.body)) {
      if (req.body[key] == "") {
        req.body[key] = null;
      }
    }

    if (isNaN(parseInt(req.body.qty)) && req.body.qty != null) {
      return res.json({
        message: "Kuantiti harus terdiri dari angka",
        status: "error",
      });
    }

    else if (req.body.customerId == null) {
      return res.json({
        message: "Pelanggan harus diisi",
        status: "error",
      });
    }
    // await Order.findAll({
    //   where: {
    //     orderCode: req.body.orderCode,
    //   },
    // }).then(result => {
    //   if(result.length != 0){
    //     throw "already exist"
    //   }
    // });
    await Order.destroy({
      where:{
        orderCode: _orderCode
      }
    })

    if (_products.length != 0) {
      
      for (const product of _products) {
        
        await Order.create({
          orderCode: req.body.orderCode,
          orderDate: req.body.orderDate,
          requestedDeliveryDate: req.body.requestedDeliveryDate,
          qty: product.qty,
          productId: product.productId,
          materialId: product.materialId,
          fabricatingMaterialId: product.fabricatingMaterialId,
          name: product.name,
          price: product.price,
          customerId: req.body.customerId,
          orderDesc: req.body.orderDesc,
          orderStatus: "Belum dikirim",
        });
      }
      createLog(req.userId, "Sales Order", "Update Sales Order "+_orderCode)
      return res.json({
        message: "Pesanan berhasil dibuat !",
        status: "success",
      });
    } else {
      throw "error products";
    }
  } catch (error) {
    var message = "";
    var field = "";

    console.log("super: "+error);
    if (error == "error products") {
      return res.json({
        message: "Masukkan setidaknya 1 produk",
        status: "error",
      });
    } else if (error == "already exist") {
      return res.json({
        message: "Kode pemesanan telah dipakai !",
        status: "error",
      });
    } else {
      // Field checking
      
      if (error.errors[0].path == "orderCode") {
        field = "Kode pesanan";
      } else if (error.errors[0].path == "orderDate") {
        field = "Tanggal pesanan";
      } else if (error.errors[0].path == "requestedDeliveryDate") {
        field = "Tanggal permintaan pengiriman";
      } else if (error.errors[0].path == "productId") {
        field = "Product";
      } else if (error.errors[0].path == "customerId") {
        field = "Pelanggan";
      } else if (error.errors[0].path == "qty") {
        field = "Kuantiti produk";
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