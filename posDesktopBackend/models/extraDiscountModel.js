import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Customer from "./customerModel.js";

const { DataTypes } = Sequelize;

const ExtraDiscount = db.define(
    "extraDiscount",
    {
      extraDiscountId: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
      },
      customerId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      amountPaid: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      discount: {
        type: DataTypes.STRING,
        allowNull: false,
      }
    },
    {
      freezeTableName: true,
      timestamps: false,
    }
  );

  ExtraDiscount.belongsTo(Customer, {
    foreignKey: "customerId",
  });
  
  Customer.hasMany(ExtraDiscount, {
    foreignKey: "customerId",
  });

export default ExtraDiscount