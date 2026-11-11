/*
 Navicat Premium Data Transfer

 Source Server         : Accresearch
 Source Server Type    : MySQL
 Source Server Version : 80200
 Source Host           : localhost:3306
 Source Schema         : ecommerce_db

 Target Server Type    : MySQL
 Target Server Version : 80200
 File Encoding         : 65001

 Date: 08/11/2026 15:19:38
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for addresses
-- ----------------------------
DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `recipient_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `street_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `is_default` tinyint(1) NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_addr_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_addr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of addresses
-- ----------------------------

-- ----------------------------
-- Table structure for admin_users
-- ----------------------------
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role` enum('admin','staff') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'staff',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin_users
-- ----------------------------
INSERT INTO `admin_users` VALUES (2, 'admin', '$2b$12$e80yq5w/98vE4H3MhZ3iEOp8c2.dF3lqXoJq6tC0yqg0Y8Z6Nq2dC', 'Wan Sokhour (Master Admin)', 'admin', 1, '2026-11-07 21:58:31');
INSERT INTO `admin_users` VALUES (3, 'staff', '$2b$12$zMrOINbQ7m60/J0ZGsHioOmSizlQbcfjTtmGZzuHnOXxc/03Zxo/G', 'Riya', 'staff', 1, '2026-11-07 23:13:50');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for cart_items
-- ----------------------------
DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE `cart_items`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT 1,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cart_item`(`user_id` ASC, `product_id` ASC) USING BTREE,
  INDEX `fk_cart_prd`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_prd` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_usr` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart_items
-- ----------------------------

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `icon_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, 'Smartphones', 'https://cdn-icons-png.flaticon.com/512/644/644458.png', '2026-11-03 22:32:31');
INSERT INTO `categories` VALUES (2, 'Laptops & Ultrabooks', 'https://cdn-icons-png.flaticon.com/512/1055/1055687.png', '2026-11-03 22:32:31');
INSERT INTO `categories` VALUES (3, 'Audio & Wireless', 'https://cdn-icons-png.flaticon.com/512/3293/3293677.png', '2026-11-03 22:32:31');
INSERT INTO `categories` VALUES (4, 'Wearables & Smartwatches', 'https://cdn-icons-png.flaticon.com/512/2972/2972531.png', '2026-11-03 22:32:31');
INSERT INTO `categories` VALUES (5, 'Chargers & Power Banks', 'https://cdn-icons-png.flaticon.com/512/2888/2888698.png', '2026-11-03 22:32:31');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1, NULL, 'Order #12 Shipping', 'Order #12 is on the way! Our delivery driver has departed.', '2026-11-06 13:39:13');
INSERT INTO `notifications` VALUES (2, NULL, 'Order #11 Delivered', 'Order #11 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 13:39:13');
INSERT INTO `notifications` VALUES (3, NULL, 'Welcome to TechHub', 'Explore our latest gadgets, discounts, and electronics collection.', '2026-11-06 13:39:13');
INSERT INTO `notifications` VALUES (4, 2, 'Order #13 Shipping', 'Order #13 is on the way! Our delivery driver has departed.', '2026-11-06 13:40:01');
INSERT INTO `notifications` VALUES (5, 2, 'Order #13 Delivered', 'Order #13 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 13:40:15');
INSERT INTO `notifications` VALUES (6, 2, 'Order #16 Confirmed', 'Thank you! Your order #16 has been placed successfully.', '2026-11-06 13:42:05');
INSERT INTO `notifications` VALUES (7, 2, 'Order #16 Shipping', 'Order #16 is on the way! Our delivery driver has departed.', '2026-11-06 13:42:15');
INSERT INTO `notifications` VALUES (8, 2, 'Order #16 Cancelled', 'Notice: Order #16 was cancelled by our store.', '2026-11-06 13:42:28');
INSERT INTO `notifications` VALUES (9, 2, 'Order #17 Confirmed', 'Thank you! Your order #17 has been placed successfully.', '2026-11-06 13:43:04');
INSERT INTO `notifications` VALUES (10, 2, 'Order #17 Shipping', 'Order #17 is on the way! Our delivery driver has departed.', '2026-11-06 13:43:12');
INSERT INTO `notifications` VALUES (11, 2, 'Order #17 Delivered', 'Order #17 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 13:43:33');
INSERT INTO `notifications` VALUES (12, 1, 'Order #18 Confirmed', 'Thank you! Your order #18 has been placed successfully.', '2026-11-06 14:26:16');
INSERT INTO `notifications` VALUES (13, 1, 'Order #19 Confirmed', 'Thank you! Your order #19 has been placed successfully.', '2026-11-06 15:14:49');
INSERT INTO `notifications` VALUES (14, 1, 'Order #19 Shipping', 'Order #19 is on the way! Our delivery driver has departed.', '2026-11-06 15:15:15');
INSERT INTO `notifications` VALUES (15, 1, 'Order #18 Shipping', 'Order #18 is on the way! Our delivery driver has departed.', '2026-11-06 15:15:18');
INSERT INTO `notifications` VALUES (16, 1, 'Order #19 Delivered', 'Order #19 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 15:15:21');
INSERT INTO `notifications` VALUES (17, 1, 'Order #18 Delivered', 'Order #18 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 15:15:23');
INSERT INTO `notifications` VALUES (18, 1, 'Order #20 Confirmed', 'Thank you! Your order #20 has been placed successfully.', '2026-11-06 15:30:21');
INSERT INTO `notifications` VALUES (19, 1, 'Order #20 Shipping', 'Order #20 is on the way! Our delivery driver has departed.', '2026-11-06 17:13:50');
INSERT INTO `notifications` VALUES (20, 1, 'Order #20 Delivered', 'Order #20 has been delivered! Thank you for shopping with TechHub.', '2026-11-06 17:13:53');
INSERT INTO `notifications` VALUES (21, 1, 'Order #20 Delivered', 'Order #20 has been delivered! Thank you for shopping with TechHub.', '2026-11-07 22:26:17');
INSERT INTO `notifications` VALUES (22, 1, 'Order #21 Confirmed', 'Thank you! Your order #21 has been placed successfully.', '2026-11-08 00:26:18');
INSERT INTO `notifications` VALUES (23, 1, 'Order #22 Confirmed', 'Thank you! Your order #22 has been placed successfully.', '2026-11-08 00:26:58');
INSERT INTO `notifications` VALUES (24, 1, 'Order #23 Confirmed', 'Thank you! Your order #23 has been placed successfully.', '2026-11-08 01:15:46');
INSERT INTO `notifications` VALUES (25, 1, 'Order #24 Confirmed', 'Thank you! Your order #24 has been placed successfully.', '2026-11-08 01:16:12');
INSERT INTO `notifications` VALUES (26, 1, 'Order #25 Confirmed', 'Thank you! Your order #25 has been placed successfully.', '2026-11-08 01:16:53');
INSERT INTO `notifications` VALUES (27, 1, 'Order #26 Confirmed', 'Thank you! Your order #26 has been placed successfully.', '2026-11-08 01:23:49');
INSERT INTO `notifications` VALUES (28, 1, 'Order #26 Shipping', 'Order #26 has departed and is on the way!', '2026-11-08 01:24:20');
INSERT INTO `notifications` VALUES (29, 1, 'Order #26 Delivered', 'Order #26 has been delivered. Thank you!', '2026-11-08 01:24:45');
INSERT INTO `notifications` VALUES (30, 1, 'Order #27 Confirmed', 'Thank you! Your order #27 has been placed successfully.', '2026-11-08 12:00:10');

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10, 2) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_item_ord`(`order_id` ASC) USING BTREE,
  INDEX `fk_item_prd`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_item_prd` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (6, 19, 1, 1, 1999.00);
INSERT INTO `order_items` VALUES (7, 20, 1, 1, 1199.00);
INSERT INTO `order_items` VALUES (8, 20, 2, 1, 1149.00);
INSERT INTO `order_items` VALUES (9, 21, 1, 1, 0.00);
INSERT INTO `order_items` VALUES (10, 21, 2, 1, 0.00);
INSERT INTO `order_items` VALUES (11, 22, 4, 1, 0.00);
INSERT INTO `order_items` VALUES (12, 22, 9, 1, 0.00);
INSERT INTO `order_items` VALUES (13, 23, 1, 1, 1199.00);
INSERT INTO `order_items` VALUES (14, 24, 1, 1, 1199.00);
INSERT INTO `order_items` VALUES (15, 25, 3, 1, 1999.00);
INSERT INTO `order_items` VALUES (16, 26, 3, 1, 1999.00);
INSERT INTO `order_items` VALUES (17, 27, 7, 1, 799.00);
INSERT INTO `order_items` VALUES (18, 27, 8, 1, 59.00);
INSERT INTO `order_items` VALUES (19, 27, 4, 1, 1849.00);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL,
  `customer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `total_amount` decimal(10, 2) NULL DEFAULT NULL,
  `delivery_fee` decimal(10, 2) NULL DEFAULT 0.00,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'Completed',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 3597.00, 0.00, 'Completed', '2026-11-05 02:05:41');
INSERT INTO `orders` VALUES (2, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 525.00, 0.00, 'Completed', '2026-11-05 02:06:10');
INSERT INTO `orders` VALUES (3, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'Cash on Delivery', 2348.00, 0.00, 'Completed', '2026-11-05 09:40:13');
INSERT INTO `orders` VALUES (4, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 933.00, 0.00, 'Completed', '2026-11-05 09:42:48');
INSERT INTO `orders` VALUES (5, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'UnionPay', 3107.00, 0.00, 'Completed', '2026-11-05 09:50:09');
INSERT INTO `orders` VALUES (6, 3, 'shuhua', '094856135', 'Preak Somroang, Takhmao, Kandal', 'UnionPay', 957.00, 0.00, 'Completed', '2026-11-05 09:51:52');
INSERT INTO `orders` VALUES (7, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 3497.00, 0.00, 'Completed', '2026-11-05 17:28:32');
INSERT INTO `orders` VALUES (8, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'UnionPay', 3497.00, 0.00, 'Completed', '2026-11-05 17:28:52');
INSERT INTO `orders` VALUES (9, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'UnionPay', 3497.00, 0.00, 'Completed', '2026-11-05 17:28:59');
INSERT INTO `orders` VALUES (10, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 649.00, 0.00, 'Completed', '2026-11-05 17:31:58');
INSERT INTO `orders` VALUES (11, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 399.00, 0.00, 'Completed', '2026-11-05 17:40:45');
INSERT INTO `orders` VALUES (12, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 648.00, 0.00, 'Delivered', '2026-11-06 11:04:17');
INSERT INTO `orders` VALUES (13, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 3048.00, 0.00, 'Delivered', '2026-11-06 13:07:17');
INSERT INTO `orders` VALUES (14, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 3048.00, 0.00, 'Delivered', '2026-11-06 13:07:28');
INSERT INTO `orders` VALUES (15, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 1199.00, 0.00, 'Delivered', '2026-11-06 13:23:38');
INSERT INTO `orders` VALUES (16, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 1274.00, 0.00, 'Cancelled', '2026-11-06 13:42:05');
INSERT INTO `orders` VALUES (17, 2, 'Sokhour', '092834764', 'Preak Somroang, Takhmao, Kandal', 'ABA PayWay', 858.00, 0.00, 'Delivered', '2026-11-06 13:43:04');
INSERT INTO `orders` VALUES (18, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 1199.00, 0.00, 'Delivered', '2026-11-06 14:26:16');
INSERT INTO `orders` VALUES (19, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 1999.00, 0.00, 'Delivered', '2026-11-06 15:14:49');
INSERT INTO `orders` VALUES (20, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 2348.00, 0.00, 'Delivered', '2026-11-06 15:30:21');
INSERT INTO `orders` VALUES (21, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 2348.00, 0.00, 'Confirmed', '2026-11-08 00:26:18');
INSERT INTO `orders` VALUES (22, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay', 1924.00, 0.00, 'Confirmed', '2026-11-08 00:26:58');
INSERT INTO `orders` VALUES (23, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay (KHQR)', 1201.00, 2.00, 'Confirmed', '2026-11-08 01:15:46');
INSERT INTO `orders` VALUES (24, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay (KHQR)', 1201.00, 2.00, 'Confirmed', '2026-11-08 01:16:12');
INSERT INTO `orders` VALUES (25, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay (KHQR)', 2001.00, 2.00, 'Confirmed', '2026-11-08 01:16:53');
INSERT INTO `orders` VALUES (26, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay (KHQR)', 2001.00, 2.00, 'Delivered', '2026-11-08 01:23:49');
INSERT INTO `orders` VALUES (27, 1, 'Luna', '093318228', 'Takhmao, kandal province', 'ABA PayWay (KHQR)', 2709.00, 2.00, 'Confirmed', '2026-11-08 12:00:10');

-- ----------------------------
-- Table structure for page_views
-- ----------------------------
DROP TABLE IF EXISTS `page_views`;
CREATE TABLE `page_views`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `visited_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 142 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of page_views
-- ----------------------------
INSERT INTO `page_views` VALUES (1, '172.20.10.2', '2026-11-04 16:57:16');
INSERT INTO `page_views` VALUES (2, '172.20.10.2', '2026-11-04 16:57:16');
INSERT INTO `page_views` VALUES (3, '172.20.10.2', '2026-11-04 16:58:31');
INSERT INTO `page_views` VALUES (4, '172.20.10.2', '2026-11-04 16:58:31');
INSERT INTO `page_views` VALUES (5, '172.20.10.2', '2026-11-04 17:00:00');
INSERT INTO `page_views` VALUES (6, '172.20.10.2', '2026-11-04 17:00:00');
INSERT INTO `page_views` VALUES (7, '172.20.10.2', '2026-11-04 17:00:02');
INSERT INTO `page_views` VALUES (8, '172.20.10.2', '2026-11-04 17:00:02');
INSERT INTO `page_views` VALUES (9, '172.20.10.2', '2026-11-04 17:00:02');
INSERT INTO `page_views` VALUES (10, '172.20.10.2', '2026-11-04 17:00:02');
INSERT INTO `page_views` VALUES (11, '172.20.10.2', '2026-11-04 17:00:31');
INSERT INTO `page_views` VALUES (12, '172.20.10.2', '2026-11-04 17:05:55');
INSERT INTO `page_views` VALUES (13, '172.20.10.2', '2026-11-04 17:05:55');
INSERT INTO `page_views` VALUES (14, '172.20.10.2', '2026-11-04 17:05:56');
INSERT INTO `page_views` VALUES (15, '172.20.10.2', '2026-11-04 17:05:56');
INSERT INTO `page_views` VALUES (16, '172.20.10.2', '2026-11-04 17:05:56');
INSERT INTO `page_views` VALUES (17, '172.20.10.2', '2026-11-04 17:05:57');
INSERT INTO `page_views` VALUES (18, '172.20.10.2', '2026-11-04 17:06:17');
INSERT INTO `page_views` VALUES (19, '172.20.10.2', '2026-11-04 17:06:30');
INSERT INTO `page_views` VALUES (20, '172.20.10.2', '2026-11-04 17:06:30');
INSERT INTO `page_views` VALUES (21, '192.168.1.4', '2026-11-05 01:08:27');
INSERT INTO `page_views` VALUES (22, '192.168.1.4', '2026-11-05 01:08:27');
INSERT INTO `page_views` VALUES (23, '192.168.1.4', '2026-11-05 01:08:27');
INSERT INTO `page_views` VALUES (24, '192.168.1.4', '2026-11-05 01:08:40');
INSERT INTO `page_views` VALUES (25, '192.168.1.4', '2026-11-05 01:08:40');
INSERT INTO `page_views` VALUES (26, '192.168.1.4', '2026-11-05 01:12:12');
INSERT INTO `page_views` VALUES (27, '192.168.1.4', '2026-11-05 01:22:48');
INSERT INTO `page_views` VALUES (28, '192.168.1.4', '2026-11-05 01:22:48');
INSERT INTO `page_views` VALUES (29, '192.168.1.4', '2026-11-05 01:46:55');
INSERT INTO `page_views` VALUES (30, '192.168.1.4', '2026-11-05 01:46:55');
INSERT INTO `page_views` VALUES (31, '192.168.1.4', '2026-11-05 01:47:04');
INSERT INTO `page_views` VALUES (32, '192.168.1.4', '2026-11-05 01:47:04');
INSERT INTO `page_views` VALUES (33, '192.168.1.4', '2026-11-05 01:47:15');
INSERT INTO `page_views` VALUES (34, '192.168.1.4', '2026-11-05 01:47:15');
INSERT INTO `page_views` VALUES (35, '127.0.0.1', '2026-11-05 01:52:19');
INSERT INTO `page_views` VALUES (36, '127.0.0.1', '2026-11-05 01:52:19');
INSERT INTO `page_views` VALUES (37, '127.0.0.1', '2026-11-05 01:52:20');
INSERT INTO `page_views` VALUES (38, '127.0.0.1', '2026-11-05 01:52:20');
INSERT INTO `page_views` VALUES (39, '127.0.0.1', '2026-11-05 01:52:20');
INSERT INTO `page_views` VALUES (40, '127.0.0.1', '2026-11-05 01:52:20');
INSERT INTO `page_views` VALUES (41, '127.0.0.1', '2026-11-05 01:52:45');
INSERT INTO `page_views` VALUES (42, '192.168.1.4', '2026-11-05 01:57:18');
INSERT INTO `page_views` VALUES (43, '127.0.0.1', '2026-11-05 01:57:53');
INSERT INTO `page_views` VALUES (44, '127.0.0.1', '2026-11-05 01:57:53');
INSERT INTO `page_views` VALUES (45, '127.0.0.1', '2026-11-05 01:57:54');
INSERT INTO `page_views` VALUES (46, '127.0.0.1', '2026-11-05 01:57:54');
INSERT INTO `page_views` VALUES (47, '127.0.0.1', '2026-11-05 01:57:54');
INSERT INTO `page_views` VALUES (48, '127.0.0.1', '2026-11-05 01:57:54');
INSERT INTO `page_views` VALUES (49, '192.168.1.4', '2026-11-05 02:01:44');
INSERT INTO `page_views` VALUES (50, '127.0.0.1', '2026-11-05 02:05:41');
INSERT INTO `page_views` VALUES (51, '127.0.0.1', '2026-11-05 02:05:41');
INSERT INTO `page_views` VALUES (52, '192.168.1.4', '2026-11-05 02:05:49');
INSERT INTO `page_views` VALUES (53, '127.0.0.1', '2026-11-05 02:06:10');
INSERT INTO `page_views` VALUES (54, '127.0.0.1', '2026-11-05 02:06:10');
INSERT INTO `page_views` VALUES (55, '192.168.1.4', '2026-11-05 02:06:19');
INSERT INTO `page_views` VALUES (56, '192.168.18.152', '2026-11-05 09:36:40');
INSERT INTO `page_views` VALUES (57, '192.168.18.152', '2026-11-05 09:36:40');
INSERT INTO `page_views` VALUES (58, '192.168.18.152', '2026-11-05 09:36:46');
INSERT INTO `page_views` VALUES (59, '192.168.18.152', '2026-11-05 09:36:46');
INSERT INTO `page_views` VALUES (60, '192.168.18.152', '2026-11-05 09:36:55');
INSERT INTO `page_views` VALUES (61, '192.168.18.152', '2026-11-05 09:36:55');
INSERT INTO `page_views` VALUES (62, '127.0.0.1', '2026-11-05 09:38:06');
INSERT INTO `page_views` VALUES (63, '127.0.0.1', '2026-11-05 09:38:06');
INSERT INTO `page_views` VALUES (64, '127.0.0.1', '2026-11-05 09:38:08');
INSERT INTO `page_views` VALUES (65, '127.0.0.1', '2026-11-05 09:38:08');
INSERT INTO `page_views` VALUES (66, '127.0.0.1', '2026-11-05 09:39:01');
INSERT INTO `page_views` VALUES (67, '127.0.0.1', '2026-11-05 09:40:13');
INSERT INTO `page_views` VALUES (68, '127.0.0.1', '2026-11-05 09:40:13');
INSERT INTO `page_views` VALUES (69, '192.168.18.152', '2026-11-05 09:40:32');
INSERT INTO `page_views` VALUES (70, '127.0.0.1', '2026-11-05 09:42:48');
INSERT INTO `page_views` VALUES (71, '127.0.0.1', '2026-11-05 09:42:48');
INSERT INTO `page_views` VALUES (72, '127.0.0.1', '2026-11-05 09:43:04');
INSERT INTO `page_views` VALUES (73, '127.0.0.1', '2026-11-05 09:43:10');
INSERT INTO `page_views` VALUES (74, '127.0.0.1', '2026-11-05 09:43:32');
INSERT INTO `page_views` VALUES (75, '127.0.0.1', '2026-11-05 09:43:33');
INSERT INTO `page_views` VALUES (76, '127.0.0.1', '2026-11-05 09:43:36');
INSERT INTO `page_views` VALUES (77, '127.0.0.1', '2026-11-05 09:43:37');
INSERT INTO `page_views` VALUES (78, '127.0.0.1', '2026-11-05 09:43:40');
INSERT INTO `page_views` VALUES (79, '192.168.18.152', '2026-11-05 09:46:19');
INSERT INTO `page_views` VALUES (80, '192.168.18.152', '2026-11-05 09:47:18');
INSERT INTO `page_views` VALUES (81, '192.168.18.152', '2026-11-05 09:47:26');
INSERT INTO `page_views` VALUES (82, '192.168.18.152', '2026-11-05 09:47:26');
INSERT INTO `page_views` VALUES (83, '192.168.18.152', '2026-11-05 09:47:31');
INSERT INTO `page_views` VALUES (84, '127.0.0.1', '2026-11-05 09:48:16');
INSERT INTO `page_views` VALUES (85, '127.0.0.1', '2026-11-05 09:48:16');
INSERT INTO `page_views` VALUES (86, '127.0.0.1', '2026-11-05 09:48:18');
INSERT INTO `page_views` VALUES (87, '127.0.0.1', '2026-11-05 09:48:18');
INSERT INTO `page_views` VALUES (88, '127.0.0.1', '2026-11-05 09:49:45');
INSERT INTO `page_views` VALUES (89, '127.0.0.1', '2026-11-05 09:50:09');
INSERT INTO `page_views` VALUES (90, '127.0.0.1', '2026-11-05 09:50:09');
INSERT INTO `page_views` VALUES (91, '127.0.0.1', '2026-11-05 09:50:13');
INSERT INTO `page_views` VALUES (92, '127.0.0.1', '2026-11-05 09:51:12');
INSERT INTO `page_views` VALUES (93, '127.0.0.1', '2026-11-05 09:51:12');
INSERT INTO `page_views` VALUES (94, '127.0.0.1', '2026-11-05 09:51:24');
INSERT INTO `page_views` VALUES (95, '127.0.0.1', '2026-11-05 09:51:25');
INSERT INTO `page_views` VALUES (96, '127.0.0.1', '2026-11-05 09:51:26');
INSERT INTO `page_views` VALUES (97, '127.0.0.1', '2026-11-05 09:51:26');
INSERT INTO `page_views` VALUES (98, '127.0.0.1', '2026-11-05 09:51:52');
INSERT INTO `page_views` VALUES (99, '127.0.0.1', '2026-11-05 09:51:52');
INSERT INTO `page_views` VALUES (100, '192.168.18.152', '2026-11-05 09:52:07');
INSERT INTO `page_views` VALUES (101, '192.168.18.152', '2026-11-05 09:52:17');
INSERT INTO `page_views` VALUES (102, '192.168.18.152', '2026-11-05 09:52:17');
INSERT INTO `page_views` VALUES (103, '192.168.18.152', '2026-11-05 09:56:26');
INSERT INTO `page_views` VALUES (104, '192.168.18.152', '2026-11-05 09:56:27');
INSERT INTO `page_views` VALUES (105, '192.168.18.152', '2026-11-05 10:45:46');
INSERT INTO `page_views` VALUES (106, '192.168.18.152', '2026-11-05 10:49:04');
INSERT INTO `page_views` VALUES (107, '127.0.0.1', '2026-11-05 16:19:03');
INSERT INTO `page_views` VALUES (108, '127.0.0.1', '2026-11-05 16:19:03');
INSERT INTO `page_views` VALUES (109, '127.0.0.1', '2026-11-05 16:19:10');
INSERT INTO `page_views` VALUES (110, '127.0.0.1', '2026-11-05 16:19:10');
INSERT INTO `page_views` VALUES (111, '127.0.0.1', '2026-11-05 16:19:26');
INSERT INTO `page_views` VALUES (112, '127.0.0.1', '2026-11-05 16:19:26');
INSERT INTO `page_views` VALUES (113, '127.0.0.1', '2026-11-05 17:07:43');
INSERT INTO `page_views` VALUES (114, '127.0.0.1', '2026-11-05 17:07:43');
INSERT INTO `page_views` VALUES (115, '127.0.0.1', '2026-11-05 17:07:44');
INSERT INTO `page_views` VALUES (116, '127.0.0.1', '2026-11-05 17:07:44');
INSERT INTO `page_views` VALUES (117, '127.0.0.1', '2026-11-05 17:18:32');
INSERT INTO `page_views` VALUES (118, '127.0.0.1', '2026-11-05 17:18:32');
INSERT INTO `page_views` VALUES (119, '127.0.0.1', '2026-11-05 17:18:33');
INSERT INTO `page_views` VALUES (120, '127.0.0.1', '2026-11-05 17:18:33');
INSERT INTO `page_views` VALUES (121, '127.0.0.1', '2026-11-05 17:18:33');
INSERT INTO `page_views` VALUES (122, '127.0.0.1', '2026-11-05 17:27:36');
INSERT INTO `page_views` VALUES (123, '127.0.0.1', '2026-11-05 17:27:36');
INSERT INTO `page_views` VALUES (124, '127.0.0.1', '2026-11-05 17:27:37');
INSERT INTO `page_views` VALUES (125, '127.0.0.1', '2026-11-05 17:27:37');
INSERT INTO `page_views` VALUES (126, '127.0.0.1', '2026-11-05 17:27:37');
INSERT INTO `page_views` VALUES (127, '127.0.0.1', '2026-11-05 17:27:57');
INSERT INTO `page_views` VALUES (128, '127.0.0.1', '2026-11-05 17:28:32');
INSERT INTO `page_views` VALUES (129, '127.0.0.1', '2026-11-05 17:28:32');
INSERT INTO `page_views` VALUES (130, '127.0.0.1', '2026-11-05 17:28:52');
INSERT INTO `page_views` VALUES (131, '127.0.0.1', '2026-11-05 17:28:52');
INSERT INTO `page_views` VALUES (132, '127.0.0.1', '2026-11-05 17:28:59');
INSERT INTO `page_views` VALUES (133, '127.0.0.1', '2026-11-05 17:28:59');
INSERT INTO `page_views` VALUES (134, '127.0.0.1', '2026-11-05 17:31:20');
INSERT INTO `page_views` VALUES (135, '127.0.0.1', '2026-11-05 17:31:20');
INSERT INTO `page_views` VALUES (136, '127.0.0.1', '2026-11-05 17:31:21');
INSERT INTO `page_views` VALUES (137, '127.0.0.1', '2026-11-05 17:31:21');
INSERT INTO `page_views` VALUES (138, '127.0.0.1', '2026-11-05 17:31:21');
INSERT INTO `page_views` VALUES (139, '127.0.0.1', '2026-11-05 17:31:33');
INSERT INTO `page_views` VALUES (140, '127.0.0.1', '2026-11-05 17:31:58');
INSERT INTO `page_views` VALUES (141, '127.0.0.1', '2026-11-05 17:31:58');

-- ----------------------------
-- Table structure for product_images
-- ----------------------------
DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `image_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_thumbnail` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_img_prod`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_img_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_images
-- ----------------------------
INSERT INTO `product_images` VALUES (1, 1, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600', 1);
INSERT INTO `product_images` VALUES (2, 2, 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600', 1);
INSERT INTO `product_images` VALUES (3, 3, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600', 1);
INSERT INTO `product_images` VALUES (4, 4, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600', 1);
INSERT INTO `product_images` VALUES (5, 5, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600', 1);
INSERT INTO `product_images` VALUES (6, 6, 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=600', 1);
INSERT INTO `product_images` VALUES (7, 7, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600', 1);
INSERT INTO `product_images` VALUES (8, 8, 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=600', 1);
INSERT INTO `product_images` VALUES (9, 9, 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600', 1);

-- ----------------------------
-- Table structure for products
-- ----------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NULL DEFAULT NULL,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `price` decimal(10, 2) NOT NULL,
  `stock_quantity` int NULL DEFAULT 0,
  `rating` decimal(2, 1) NULL DEFAULT 5.0,
  `specifications` json NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_prod_cat`(`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_prod_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products
-- ----------------------------
INSERT INTO `products` VALUES (1, 1, 'iPhone 15 Pro Max', 'Apple', 'A17 Pro chip, Titanium design, 48MP camera system with 5x telephoto optical zoom.', 1199.00, 30, 4.9, '{\"screen\": \"6.7 inch OLED\", \"battery\": \"4422 mAh\", \"storage\": \"256GB\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793776716_81UKVHM77GL._AC_SL1500_.jpg');
INSERT INTO `products` VALUES (2, 1, 'Samsung Galaxy S24 Ultra', 'Samsung', 'Snapdragon 8 Gen 3 for Galaxy, titanium frame, 200MP camera with Galaxy AI suite.', 1149.00, 32, 4.8, '{\"pen\": \"Included\", \"screen\": \"6.8 inch AMOLED 120Hz\", \"storage\": \"512GB\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793776668_71qeTVe5d1L._AC_SX679_.jpg');
INSERT INTO `products` VALUES (3, 2, 'MacBook Pro 14\" (M3 Pro)', 'Apple', '11-core CPU, 14-core GPU, Liquid Retina XDR display, incredible all-day battery life.', 1999.00, 17, 4.9, '{\"ram\": \"18GB\", \"ssd\": \"512GB\", \"display\": \"Liquid Retina XDR\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793776148_51ZqjuoQFWL._AC_SL1200_.jpg');
INSERT INTO `products` VALUES (4, 2, 'MSI Stealth 16 Studio', 'MSI', 'Ultra-thin gaming laptop, Intel Core i9-13900H, GeForce RTX 4070 8GB GDDR6.', 1849.00, 13, 4.7, '{\"gpu\": \"RTX 4070\", \"ram\": \"32GB DDR5\", \"ssd\": \"1TB NVMe\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793776106_71UUyEKL46L._AC_SX466_.jpg');
INSERT INTO `products` VALUES (5, 3, 'Sony WH-1000XM5', 'Sony', 'Industry-leading noise cancelation with two processors and 8 microphones for superior call quality.', 399.00, 48, 4.8, '{\"battery_life\": \"30 hrs\", \"connectivity\": \"Bluetooth 5.2\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793776055_61O3iMlnJIL._AC_SX466_.jpg');
INSERT INTO `products` VALUES (6, 3, 'AirPods Pro (2nd Gen, USB-C)', 'Apple', 'Up to 2x more Active Noise Cancellation, Adaptive Audio, and Transparency mode.', 249.00, 74, 4.9, '{\"port\": \"USB-C\", \"features\": \"MagSafe, Spatial Audio\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793775411_41KJmvuQu4L._AC_SX466_.jpg');
INSERT INTO `products` VALUES (7, 4, 'Apple Watch Ultra 2', 'Apple', 'Rugged 49mm titanium case, precision dual-frequency GPS, up to 36 hours battery life.', 799.00, 22, 4.9, '{\"casing\": \"Titanium\", \"water_resistance\": \"100m\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793775374_71eBoSK6WmL._AC_SX466_.jpg');
INSERT INTO `products` VALUES (8, 4, 'Huawei Band 9', 'Huawei', 'Lightweight comfortable design, advanced sleep health management, 14-day battery.', 59.00, 87, 4.6, '{\"battery\": \"14 days\", \"sensors\": \"TruSeen 5.5, SpO2\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793775317_51SKwj613SL._AC_UL232_SR232232_.jpg');
INSERT INTO `products` VALUES (9, 5, 'Anker Prime 100W GaN Wall Charger', 'Anker', 'Ultra-compact 3-port fast wall charger with GaN technology for MacBooks and phones.', 75.00, 90, 4.8, '{\"ports\": \"2x USB-C, 1x USB-A\", \"output\": \"100W Max\"}', '2026-11-03 22:32:31', 'http://127.0.0.1:5000/uploads/1793775194_61R3k6I3uvL._AC_UL450_SY450_QL70_.jpg');
INSERT INTO `products` VALUES (10, 1, 'iPhone 16 Pro Max 256GB', 'Apple', 'Grade 5 titanium design with A18 Pro chip, 48MP Fusion camera system, and Camera Control button.', 1199.00, 14, 4.9, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (11, 1, 'Samsung Galaxy Z Fold6', 'Samsung', 'Ultra-slim foldable display powered by Snapdragon 8 Gen 3 with Galaxy AI multitasking features.', 1799.00, 8, 4.8, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (12, 2, 'Dell XPS 16 OLED Laptop', 'Dell', 'Intel Core Ultra 9, 32GB RAM, 1TB SSD, RTX 4070 Graphics with 4K InfinityEdge OLED Touchscreen.', 2399.00, 10, 4.7, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (13, 2, 'ASUS ROG Zephyrus G14 Gaming Laptop', 'ASUS', 'AMD Ryzen 9 8945HS, NVIDIA RTX 4060, 3K 120Hz OLED display in a CNC aluminum ultralight chassis.', 1599.00, 10, 4.8, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (14, 3, 'Sony WF-1000XM5 True Wireless Earbuds', 'Sony', 'Industry-leading active noise canceling earbuds with LDAC high-resolution wireless audio and dual processors.', 279.00, 24, 4.7, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (15, 3, 'Bose QuietComfort Ultra Headphones', 'Bose', 'World-class spatial audio with CustomTune sound calibration and ultra-plush noise-isolating ear cushions.', 429.00, 11, 4.8, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (16, 4, 'Apple Watch Series 10 (GPS + Cellular)', 'Apple', 'Thinnest Apple Watch ever with larger wide-angle OLED display, sleep apnea tracking, and faster charging.', 499.00, 18, 4.9, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (17, 4, 'Samsung Galaxy Watch Ultra (Titanium)', 'Samsung', 'Rugged titanium case built for extreme adventures with 100m water resistance, dual-frequency GPS, and 100-hour battery.', 649.00, 8, 4.6, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (18, 5, 'Baseus Blade HD 100W Power Bank 20000mAh', 'Baseus', 'Ultra-thin 18mm power bank delivering 100W Power Delivery high-speed output for laptops, tablets, and phones.', 89.00, 29, 4.7, NULL, '2026-11-05 09:46:06', '/uploads/1793846846_31ONMo8yLgL._AC_.jpg');
INSERT INTO `products` VALUES (19, 5, 'Keychron Q1 Max Wireless Mechanical Keyboard', 'Keychron', 'Full CNC aluminum gasket mount keyboard with 2.4GHz wireless, Bluetooth 5.1, hot-swappable switches, and acoustic foam.', 219.00, 13, 4.9, NULL, '2026-11-05 09:46:06', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80');
INSERT INTO `products` VALUES (20, 5, 'Anker Laptop Power Bank 25,000mAh', 'Anker', 'Triple 100W USB-C Ports for Multi-Device Charging: Ideal for laptop users, this 25,000mAh power bank features three 100W USB-C ports for simultaneous charging—perfect for remote work, home offices, or powering up multiple devices on the go.\r\n25,000mAh for Long-Haul Power: Tackle week-long trips or extended camping with 25,000mAh capacity and ultra-fast recharge speeds for the power bank when used with a 100W or higher charger. (Note: Complies with 100Wh airline restrictions and is airline carry-on friendly.)\r\nDual Built-In Cables for Travel: Features two USB-C cables, one extendable up to 2.3 ft with 20,000 retractions, and another at 0.98 ft cable that doubles as a durable carrying strap capable of enduring more than 20,000 bends. Built to handle family travel, outdoor activities, and emergency backup needs.\r\nCharge 4 Devices at Once: Power up smartphones, tablets, or other USB-enabled devices thanks to dual USB-C cables, a USB-A port, and a USB-C port.\r\n65W High-Speed Charging: Delivers up to 65W output. Maximum output of 65W is available only when using a single port. When multiple ports are in use, the USB-C1 port provides up to 45W, and the USB-C2 port provides up to 20W. （Note: Output also varies based on the connected device.）\r\nVersatile Dual-Function Charging: This compact 9,600mAh power bank also serves as a wall charger and comes with a charging cable for flexible use.\r\nSmall Size, Monumental Power: The 10.76 oz ultra-compact power bank fits easily into any pocket or bag, delivering substantial energy without the bulk.', 35.00, 20, 5.0, NULL, '2026-11-05 09:56:26', '/uploads/1793847386_71AD3ZcRdTL._AC_SX466_.jpg');

-- ----------------------------
-- Table structure for search_logs
-- ----------------------------
DROP TABLE IF EXISTS `search_logs`;
CREATE TABLE `search_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `query` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `searched_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of search_logs
-- ----------------------------
INSERT INTO `search_logs` VALUES (1, 'iphone', '2026-11-04 16:13:58');
INSERT INTO `search_logs` VALUES (2, 'iphone', '2026-11-04 16:27:17');

-- ----------------------------
-- Table structure for user_logins
-- ----------------------------
DROP TABLE IF EXISTS `user_logins`;
CREATE TABLE `user_logins`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL,
  `logged_in_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Records of user_logins
-- ----------------------------
INSERT INTO `user_logins` VALUES (1, 2, '2026-11-04 17:00:01');
INSERT INTO `user_logins` VALUES (2, 2, '2026-11-04 17:05:56');
INSERT INTO `user_logins` VALUES (3, 1, '2026-11-05 01:52:19');
INSERT INTO `user_logins` VALUES (4, 1, '2026-11-05 01:57:53');
INSERT INTO `user_logins` VALUES (5, 1, '2026-11-05 09:38:07');
INSERT INTO `user_logins` VALUES (6, 2, '2026-11-05 09:48:17');
INSERT INTO `user_logins` VALUES (7, 3, '2026-11-05 09:51:26');
INSERT INTO `user_logins` VALUES (8, 2, '2026-11-05 17:07:44');
INSERT INTO `user_logins` VALUES (9, 1, '2026-11-05 17:18:33');
INSERT INTO `user_logins` VALUES (10, 1, '2026-11-05 17:27:37');
INSERT INTO `user_logins` VALUES (11, 1, '2026-11-05 17:31:21');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'Luna', 'luna123@gmail.com', '$2b$12$FjFupyQcZHwi8kA6tz8/Ru4V32aSNJPkhy0pOZxV7hTIVayQ8z9Sq', '093318228', NULL, '2026-11-04 15:41:12', '2026-11-04 15:42:40', 'Takhmao, kandal province');
INSERT INTO `users` VALUES (2, 'Sokhour', 'sokhourwan@gmail.com', '$2b$12$0umuyQ.9eCO1O0Cs2pqAs.IXkieXR4ZwLxavNTmncMr5X.YzkgPPu', '092834764', NULL, '2026-11-04 15:45:14', '2026-11-04 15:45:14', NULL);
INSERT INTO `users` VALUES (3, 'shuhua', 'shuhua123@gmail.com', '$2b$12$XANAghZnHJfzMZYzSbN3lO94llN.0oU7S2zK4XzOJtuCLigvG3ktm', '094856135', NULL, '2026-11-05 09:51:14', '2026-11-05 09:51:14', NULL);

-- ----------------------------
-- Table structure for wishlist
-- ----------------------------
DROP TABLE IF EXISTS `wishlist`;
CREATE TABLE `wishlist`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_wish_item`(`user_id` ASC, `product_id` ASC) USING BTREE,
  INDEX `fk_wish_prd`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_wish_prd` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_wish_usr` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wishlist
-- ----------------------------
INSERT INTO `wishlist` VALUES (1, 1, 1, '2026-11-08 00:25:35');
INSERT INTO `wishlist` VALUES (2, 1, 6, '2026-11-08 00:25:49');
INSERT INTO `wishlist` VALUES (3, 2, 1, '2026-11-08 00:35:48');

SET FOREIGN_KEY_CHECKS = 1;
