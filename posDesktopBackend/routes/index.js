import express from "express";

import multer from "multer";

const upload = multer({dest: 'uploads/'})

/* import your controller here, construct the function directly */

import { getLogs } from "../controllers/activityLog.js";

import { getCustomers, createCustomer, updateCustomer, softDeleteCustomer } from "../controllers/customer.js";

import { getSuppliers, createSupplier, updateSupplier, softDeleteSupplier } from "../controllers/supplier.js";

import { getUsers, register, } from "../controllers/user.js";

import { getUserAccounts, createUser, logout, login, updateUser, softDeleteUser } from "../controllers/userAccount.js";

import { createColor, getColors, updateColor, softDeleteColor } from "../controllers/color.js";

import { getTypes, createType, updateType, softDeleteType } from "../controllers/type.js";

import { getRunningOutProduct } from "../controllers/homestat.js";

import {
    getOrders,
    createOrder,
    updateOrder,
    getOrderGrouped,
    getOrderById,
    checkOrderValid,
} from "../controllers/order.js";

import {
    getDeliveries,
    createDelivery,
    getDeliveryOrder,
} from "../controllers/delivery.js";

import {
    createProduct,
    updateProduct,
    getProducts,
    getProduct,
    softDeletedProduct
} from "../controllers/product.js";

import {
    createMaterial,
    getMaterials,
    getMaterial,
    updateMaterial,
    softDeleteMaterial,
} from "../controllers/material.js";

import {
    getProductions,
    createProduction,
    getProductionGrouped,
    getProductionByCode,
    deleteProduction,
} from "../controllers/production.js";

import {
    createFabricatingMaterial,
    getFabricatingMaterials,
    getFabricatingMaterial,
    updateFabricatingMaterial,
    softDeleteFabricatingMaterial
} from "../controllers/fabricatingMaterial.js"

import {
    getSales,
    createSale,
    getSaleOrder,
    getSaleOrders,
    getSaleAvailOrder,
} from "../controllers/sale.js";

import {
    getPaymentById,
    getPayments,
    createPayment,
} from "../controllers/payment.js";

import {
    getMaterialPurchases,
    createMaterialPurchase,
    getMaterialPurchaseGrouped,
    getMaterialPurchaseByCode,
    deletePurchase,
} from "../controllers/materialPurchase.js";

import {
    getMaterialSpendingByCode,
    getMaterialSpendingsGrouped,
    getMaterialSpendings,
    createMaterialSpending,
    deleteSpending,
} from "../controllers/materialSpending.js";

import { getProfile, updateProfile, createProfile } from "../controllers/profile.js";

import { verifyToken } from "../middleware/verifyToken.js";

import { refreshToken } from "../controllers/refreshToken.js";
import { createAdjustment, getAdjustment, getAdjustments } from "../controllers/adjustment.js";

const router = express.Router();


// Refresh Token & Auth
router.post("/login", login);
router.get("/token", refreshToken);
router.delete("/logout", logout);


// User Route
router.get("/users", verifyToken, getUsers);
router.post("/user", verifyToken, register);

// User Account Route
router.get("/userAccounts", verifyToken, getUserAccounts);
router.post("/account", verifyToken, createUser);
router.put("/account", verifyToken, updateUser);
router.put("/account/delete", verifyToken, softDeleteUser);

// Customer Route
router.get("/customers", getCustomers);
router.post("/customer", verifyToken, createCustomer);
router.put("/customer", verifyToken, updateCustomer);
router.put("/customer/delete", verifyToken, softDeleteCustomer);

// Supplier Route
router.get("/suppliers", verifyToken, getSuppliers);
router.post("/supplier", verifyToken, createSupplier);
router.put("/supplier", verifyToken, updateSupplier);
router.put("/supplier/delete", verifyToken, softDeleteSupplier);

// Product Route
router.post("/product", verifyToken, createProduct);
router.put("/product", verifyToken, updateProduct);
router.put("/product/delete", verifyToken, softDeletedProduct);
router.get("/products", verifyToken, getProducts);
router.get("/product/:productId", verifyToken, getProduct);

// Color Route
router.get("/colors", verifyToken, getColors);
router.post("/color", verifyToken, createColor);
router.put("/color", verifyToken, updateColor);
router.put("/color/delete", verifyToken, softDeleteColor);


// Type Route
router.get("/types", verifyToken, getTypes);
router.post("/type", verifyToken, createType);
router.put("/type", verifyToken, updateType);
router.put("/type/delete", verifyToken, softDeleteType);


// Order route
router.get("/orders", verifyToken, getOrders);
router.get("/orders/grouped", verifyToken, getOrderGrouped);
router.get("/order", verifyToken, getOrderById);
router.post("/order", verifyToken, createOrder);
router.put("/order", verifyToken, updateOrder);
router.post("/order/check", verifyToken, checkOrderValid);

// Delivery route
router.get("/deliveries", verifyToken, getDeliveries);
router.get("/delivery/order", verifyToken, getDeliveryOrder);
router.post("/delivery", verifyToken, createDelivery);

// Sale route
router.get("/sales", verifyToken, getSales);
router.get("/sale/order", verifyToken, getSaleOrder);
router.get("/sale/orders", verifyToken, getSaleOrders);
router.get("/sale/order/avail", verifyToken, getSaleAvailOrder);
router.post("/sale", verifyToken, createSale);
router.put("/sale", verifyToken, createSale);

// Payment route
router.get("/payments", verifyToken, getPayments);
router.get("/payment", verifyToken, getPaymentById);
router.post("/payment", verifyToken, createPayment);

// Material route
router.get("/materials", verifyToken, getMaterials);
router.post("/material", verifyToken, createMaterial);
router.put("/material", verifyToken, updateMaterial);
router.put("/material/delete", verifyToken, softDeleteMaterial);

// FabricatingMaterial route
router.get("/fabricatingMaterials", getFabricatingMaterials);
router.post("/fabricatingMaterial", verifyToken, createFabricatingMaterial);
router.put("/fabricatingMaterial", verifyToken, updateFabricatingMaterial);
router.put("/fabricatingMaterial/delete", verifyToken, softDeleteFabricatingMaterial);

// Productions route
router.get("/productions", verifyToken, getProductions);
router.get("/productions/grouped", verifyToken, getProductionGrouped);
router.get("/production", verifyToken, getProductionByCode);
router.post("/production", verifyToken, createProduction);
router.put("/production", verifyToken, deleteProduction);

// Material Purchase route
router.get("/material_purchases", verifyToken, getMaterialPurchases);
router.get("/material_purchases/grouped", verifyToken, getMaterialPurchaseGrouped);
router.get("/material_purchase", verifyToken, getMaterialPurchaseByCode);
router.post("/material_purchase", verifyToken, upload.single('image'), createMaterialPurchase);
router.put("/material_purchase", verifyToken, deletePurchase);

// Material Spending route
router.get("/material_spendings", verifyToken, getMaterialSpendings);
router.get("/material_spendings/grouped", verifyToken, getMaterialSpendingsGrouped);
router.get("/material_spending", verifyToken, getMaterialSpendingByCode);
router.post("/material_spending", verifyToken, createMaterialSpending);
router.put("/material_spending", verifyToken, deleteSpending);

// Profile route
router.get("/profile", verifyToken, getProfile);
router.put("/profile", verifyToken, updateProfile);
router.post("/profile", verifyToken, createProfile);

// Adjustment Route
router.post("/adjustment", verifyToken, createAdjustment);
router.get("/adjustments", verifyToken, getAdjustments);

// Log Route
router.get("/logs", getLogs)

// Home route
router.get("/home", verifyToken, getRunningOutProduct);
export default router;