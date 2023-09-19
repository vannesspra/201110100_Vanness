import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Product from "./productModel.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js";

const { DataTypes } = Sequelize;

const Production = db.define(
    "production", {
        productionId: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            allowNull: false,
            autoIncrement: true,
        },
        productionCode: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        productionDate: {
            type: DataTypes.DATE,
            allowNull: false,
        },
        productId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        fabricatingMaterialId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        productionQty: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        productionDesc: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
    }, {
        freezeTableName: true,
        timestamps: false,
    }
);

Production.belongsTo(Product, {
    foreignKey: "productId",
});

Product.hasMany(Production, {
    foreignKey: "productId",
});
Production.belongsTo(FabricatingMaterial, {
    foreignKey: "fabricatingMaterialId",
});

FabricatingMaterial.hasMany(Production, {
    foreignKey: "fabricatingMaterialId",
});

export default Production;