import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Customer = db.define(
  "customer",
  {
    customerId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    customerCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    customerName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    customerAddress: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    customerPhoneNumber: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    customerEmail: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    customerContactPerson: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    discountOne:{
      type: DataTypes.STRING,
      allowNull: true
    },
    discountTwo:{
      type: DataTypes.STRING,
      allowNull: true
    },
    paymentType:{
      type: DataTypes.STRING,
      allowNull: false
    },
    paymentTerm:{
      type: DataTypes.STRING,
      allowNull: true
    },
    tax: {
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

export default Customer;
