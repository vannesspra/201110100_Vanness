import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Product from "./productModel.js";
import Material from "./materialModel.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js";

const { DataTypes } = Sequelize;

const Adjustment = db.define(
  "adjustment",
  {
    adjustmentId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    adjustmentCode: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    adjustmentDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    materialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    fabricatingMaterialId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    formerQty:{
      type: DataTypes.STRING,
      allowNull: false,
    },
    adjustedQty:{
      type: DataTypes.STRING,
      allowNull: false,
    },
    adjustmentReason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    adjustmentDesc: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

Adjustment.belongsTo(Product, {
  foreignKey: "productId",
});

Product.hasMany(Adjustment, {
  foreignKey: "productId",
});

Adjustment.belongsTo(Material, {
  foreignKey: "materialId",
});

Material.hasMany(Adjustment, {
  foreignKey: "materialId",
});

Adjustment.belongsTo(FabricatingMaterial, {
  foreignKey: "fabricatingMaterialId"
})

FabricatingMaterial.hasMany(Adjustment, {
  foreignKey: "fabricatingMaterialId"
})

export default Adjustment;
