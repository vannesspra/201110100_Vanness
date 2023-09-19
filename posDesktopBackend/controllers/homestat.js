import Product from "../models/productModel.js";
import ProductColor from "../models/productColorModel.js";
import Type from "../models/typeModel.js";
import Color from "../models/colorModel.js";

import Order from "../models/orderModel.js";
import Delivery from "../models/deliveryModel.js";
import Customer from "../models/customerModel.js";


import Sale from "../models/invoiceModel.js";
import Payment from "../models/paymentModel.js";

export const getRunningOutProduct = async (req, res) => {
    try {
        //Products
        var finalProducts = [];
        var finalProductLength = [];
        var initialProductLength = [];

        //Transactions
        var succeedTransactions = [];
        var finalTransactionLength = [];
        var initialTransactionLength = [];


        //Orders
        var unprocessedOrders = [];
        var finalOrderLength = [];
        var initialOrderLength = [];

        await Product.findAll({
            include: [{
                    model: ProductColor,
                    required: false,
                    include: [{
                        model: Color,
                        required: false,
                    }, ],
                },
                {
                    model: Type,
                    required: true,
                },
            ],

        }, {
            subQuery: false,
        }).then((response) => {

            var products = response;
            initialProductLength = products.length;
            for (const product of products) {
                if (parseInt(product.productQty) < parseInt(product.productMinimumStock)) {
                    finalProducts.push(product);
                }
            }
            finalProductLength = finalProducts.length


        });

        await Order.findAll({
            include: [{
                    model: Delivery,
                    required: false,
                },
                {
                    model: Product,
                    required: true,
                },
                {
                    model: Customer,
                    required: true,
                },
            ],
            group: "orderCode",
        }, {
            subQuery: false,
        }).then((response) => {
            var orders = response;
            initialOrderLength = response.length;
            unprocessedOrders = [];
            for (const order of orders) {
                if (order.orderStatus == "Belum dikirim") {
                    unprocessedOrders.push(order);
                }
            }
            finalOrderLength = unprocessedOrders.length
        })
        await Sale.findAll({
            // where: {
            //     saleStatus: "Sudah dibayar"
            // }
            include: [
                {
                  model: Payment,
                },
              ],
        }, {
            subQuery: false,
        }).then((response) => {
            var transactions = response;
            initialTransactionLength = transactions.length;

            for (const transaction of transactions) {
                if (transaction.saleStatus == "Sudah dibayar") {
                    succeedTransactions.push(transaction);
                }
            }
            finalTransactionLength = succeedTransactions.length
        });

        return res.json({
            message: "",
            status: "success",
            data: {
                products: {
                    maxCount: initialProductLength,
                    count: finalProductLength,
                    data: finalProducts
                },
                orders: {
                    maxCount: initialOrderLength,
                    count: finalOrderLength,
                    data: unprocessedOrders
                },
                transactions: {
                    maxCount: initialTransactionLength,
                    count: finalTransactionLength,
                    data: succeedTransactions
                }
            }
        });
    } catch (error) {
        return res.json({
            message: error.message,
            status: "error",
            data: []
        });
    }
}