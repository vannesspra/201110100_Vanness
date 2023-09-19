import { ENUM, Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Sale = db.define(
  "sale",
  {
    saleId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    saleCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    saleDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    saleDeadline: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    paymentType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    paymentTerm:{
      type: DataTypes.STRING,
      allowNull: true
    },
    discountOnePercentage: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    discountTwoPercentage: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    extraDiscountPercentage: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    tax: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    saleDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    saleStatus: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

export default Sale;
