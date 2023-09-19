import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Type from "./typeModel.js";
import Color from "./colorModel.js";

const { DataTypes } = Sequelize;

const Product = db.define(
  "product",
  {
    productId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    productCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    productName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    typeId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    colorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    productPrice: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    productDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    productMinimumStock: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    productQty: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    isDeleted: {
      type: DataTypes.BOOLEAN,
      allowNull:false
    }
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

Product.belongsTo(Type, {
  foreignKey: "typeId",
});

Type.hasMany(Product, {
  foreignKey: "typeId",
});

Product.belongsTo(Color, {
  foreignKey: "colorId",
});

Color.hasMany(Product, {
  foreignKey: "colorId",
});

export default Product;
