import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Product from "./productModel.js";
import Material from "./materialModel.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js";
import Customer from "./customerModel.js";
import Delivery from "./deliveryModel.js";
import Sale from "./invoiceModel.js";

const { DataTypes } = Sequelize;

const Order = db.define(
  "order",
  {
    orderId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    orderCode: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    orderDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    requestedDeliveryDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    qty: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    materialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    fabricatingMaterialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    price: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    customerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    orderDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    orderStatus: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    deliveryId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    saleId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

Order.belongsTo(Product, {
  foreignKey: "productId",
});

Product.hasMany(Order, {
  foreignKey: "productId",
});

Order.belongsTo(Material, {
  foreignKey: "materialId",
});

Material.hasMany(Order, {
  foreignKey: "materialId",
});

Order.belongsTo(FabricatingMaterial, {
  foreignKey: "fabricatingMaterialId",
});

FabricatingMaterial.hasMany(Order, {
  foreignKey: "fabricatingMaterialId",
});

Order.belongsTo(Customer, {
  foreignKey: "customerId",
});

Customer.hasMany(Order, {
  foreignKey: "customerId",
});

Order.belongsTo(Delivery, {
  foreignKey: "deliveryId",
});

Delivery.hasMany(Order, {
  foreignKey: "deliveryId",
});

Order.belongsTo(Sale, {
  foreignKey: "saleId",
});

Sale.hasMany(Order, {
  foreignKey: "saleId",
});

export default Order;
