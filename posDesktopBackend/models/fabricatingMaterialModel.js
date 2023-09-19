import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Color from "./colorModel.js";

const { DataTypes } = Sequelize;

const FabricatingMaterial = db.define(
    "fabricatingMaterial", {
        fabricatingMaterialId: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            allowNull: false,
            autoIncrement: true,
        },
        fabricatingMaterialCode: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        fabricatingMaterialName: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        colorId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        fabricatingMaterialUnit: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        fabricatingMaterialMinimumStock: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        fabricatingMaterialQty: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        fabricatingMaterialPrice: {
            type: DataTypes.STRING,
            allowNull: false,
          },
        isDeleted: {
            type: DataTypes.BOOLEAN,
            allowNull: false
        },
    }, {
        freezeTableName: true,
        timestamps: false,
    }
);

FabricatingMaterial.belongsTo(Color, {
    foreignKey: "colorId",
});

Color.hasMany(FabricatingMaterial, {
    foreignKey: "colorId",
});

export default FabricatingMaterial;