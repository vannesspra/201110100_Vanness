import { Sequelize } from "sequelize";
import db from "../config/database.js";
import Material from "./materialModel.js";
import Product from "./productModel.js";
import FabricatingMaterial from "./fabricatingMaterialModel.js"
import Supplier from "./supplierModel.js";

const { DataTypes } = Sequelize;

const MaterialPurchase = db.define(
  "materialPurchase",
  {
    materialPurchaseId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      autoIncrement: true,
    },
    materialPurchaseCode: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    materialPurchaseDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    materialPurchaseQty: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    supplierId: {
      type: DataTypes.INTEGER,
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
    taxAmount: {
      type: DataTypes.STRING,
      allowNull: true
    },
    taxInvoiceNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    taxInvoiceImg: {
      type: DataTypes.STRING,
      allowNull: true
    }
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

MaterialPurchase.belongsTo(Material, {
  foreignKey: "materialId",
});

Material.hasMany(MaterialPurchase, {
  foreignKey: "materialId",
});

MaterialPurchase.belongsTo(Product, {
  foreignKey: "productId",
});

Product.hasMany(MaterialPurchase, {
  foreignKey: "productId",
});

MaterialPurchase.belongsTo(FabricatingMaterial, {
  foreignKey: "fabricatingMaterialId",
});

FabricatingMaterial.hasMany(MaterialPurchase, {
  foreignKey: "fabricatingMaterialId",
});

MaterialPurchase.belongsTo(Supplier, {
  foreignKey: "supplierId",
});

Supplier.hasMany(MaterialPurchase, {
  foreignKey: "supplierId",
});

export default MaterialPurchase;
