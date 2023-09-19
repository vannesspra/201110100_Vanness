import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import path from 'path';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);

const __dirname = path.dirname(__filename);
import db from "./config/database.js";
import router from "./routes/index.js";

/*  Uncomment & import a model to create a table, comment it again if it already created */
import Users from "./models/userModel.js";
import Color from "./models/colorModel.js";
import Customer from "./models/customerModel.js";
import ProductColor from "./models/productColorModel.js";
import Product from "./models/productModel.js";
import Profile from "./models/profileModel.js";
import Supplier from "./models/supplierModel.js";
import Type from "./models/typeModel.js";
import User from "./models/userModel.js";
import Delivery from "./models/deliveryModel.js";
import Order from "./models/orderModel.js";
import Sale from "./models/invoiceModel.js";
import Payment from "./models/paymentModel.js";
import Material from "./models/materialModel.js";
import FabricatingMaterial from "./models/fabricatingMaterialModel.js";
import Production from "./models/productionModel.js";
import MaterialPurchase from "./models/materialPurchaseModel.js";
import MaterialSpending from "./models/materialSpendingModel.js";
import Adjustment from "./models/adjustmentModel.js";
import ExtraDiscount from "./models/extraDiscountModel.js";
import SupplierProduct from "./models/supplierProductModel.js";
import ActivityLog from "./models/activityLogModel.js";

dotenv.config();
const app = express();

var hostname = 'localhost';
var PORT = 3000;

try {
  await db.authenticate();
  console.log("Database Connented");

  /*  Uncomment & import to create a table, comment it again if it already created */
  await Users.sync();
  await Color.sync();
  await Customer.sync();
  await Type.sync();
  await Product.sync();
  await ProductColor.sync();
  await Profile.sync();
  await Supplier.sync();
  await User.sync();
  await Delivery.sync();
  await Sale.sync();
  await Material.sync();
  await FabricatingMaterial.sync();
  await Order.sync();
  await Payment.sync();
  await Production.sync();
  await MaterialPurchase.sync();
  await MaterialSpending.sync();
  await Adjustment.sync();
  await ExtraDiscount.sync();
  await SupplierProduct.sync();
  await ActivityLog.sync();
} catch (error) {
  console.error(error);
}


app.use(cors({credentials:true}))
app.use(cookieParser());
app.use(express.json());

app.use(router);
app.use('/uploads', express.static(__dirname + '/uploads/'));
app.listen(PORT, () => {
  console.log("App listening on port 3000!");
});
