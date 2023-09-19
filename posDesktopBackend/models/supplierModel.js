import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const Supplier = db.define('supplier', {
    supplierId: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true
    },
    supplierCode: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,

    },
    supplierName: {
        type: DataTypes.STRING,
        allowNull: false
    },
    supplierAddress: {
        type: DataTypes.STRING,
        allowNull: false
    },
    supplierPhoneNumber: {
        type: DataTypes.STRING,
        allowNull: false
    },
    supplierEmail: {
        type: DataTypes.STRING,
        allowNull: false
    },
    supplierContactPerson: {
        type: DataTypes.STRING,
        allowNull: false
    },
    paymentType: {
        type: DataTypes.STRING,
        allowNull: false
    },
    paymentTerm: {
        type: DataTypes.STRING,
        allowNull: true
    },
    supplierTax: {
        type: DataTypes.STRING,
        allowNull: false
    },
    isDeleted: {
        type: DataTypes.BOOLEAN,
        allowNull:false
      }
}, {
    freezeTableName: true,
    timestamps: false
})

export default Supplier;