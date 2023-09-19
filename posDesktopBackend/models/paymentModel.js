import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Sale from "./invoiceModel.js";

const { DataTypes } = Sequelize;

const Payment = db.define(
  "payment",
  {
    paymentId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    paymentCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    paymentDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    paymentDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    saleId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

Payment.belongsTo(Sale, {
  foreignKey: "saleId",
});

Sale.hasMany(Payment, {
  foreignKey: "saleId",
});

export default Payment;
