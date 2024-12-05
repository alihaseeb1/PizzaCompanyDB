-- Create the database
DROP DATABASE IF EXISTS PizzaCompany;
CREATE DATABASE PizzaCompany;
USE PizzaCompany;

-- Table: user
CREATE TABLE `user` (
    userId                  INT PRIMARY KEY AUTO_INCREMENT,
    firstName               VARCHAR(50) NOT NULL,
    lastName                VARCHAR(50) NOT NULL,
    gender                  CHAR(1) NOT NULL,
    dateOfBirth             DATE NOT NULL,
    phoneNumber             VARCHAR(20) UNIQUE NOT NULL,
    email                   VARCHAR(100) UNIQUE NOT NULL,
    passwordHash            VARCHAR(100) NOT NULL,
    taxId                   VARCHAR(10),
    company                 VARCHAR(100),
    taxInformationAddress   VARCHAR(200),
    postalCode              VARCHAR(10),

    CHECK (gender IN ('M', 'F'))
);

-- Table: membership
CREATE TABLE membership (
	membershipId    INT PRIMARY KEY AUTO_INCREMENT,
    userId          INT UNIQUE NOT NULL,
	totalPoint      INT NOT NULL,
    tierUpdateDate  DATETIME NOT NULL,

    FOREIGN KEY (userId) REFERENCES `user`(userId)
);

-- Table: savedDeliveryAddress (references user table)
CREATE TABLE savedDeliveryAddress (
    savedDeliveryAddressId  INT PRIMARY KEY AUTO_INCREMENT,
    phoneNumber             VARCHAR(20) NOT NULL,
    remarks                 VARCHAR(200),
    houseNumber             VARCHAR(10) NOT NULL,
    buildingNumber          VARCHAR(10),
    mapAddress              VARCHAR(50),
    addressLabel            TEXT NOT NULL,
    userId                  INT NOT NULL,

    FOREIGN KEY (userId) REFERENCES user(userId)
);

-- Table: branch
CREATE TABLE branch (
    branchId    INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    houseNumber VARCHAR(50) NOT NULL,
    subDistrict VARCHAR(50) NOT NULL,
    district    VARCHAR(50) NOT NULL,
    province    VARCHAR(50) NOT NULL,
    openingTime TIME NOT NULL,
    closingTime TIME NOT NULL
);

-- Table: employee (references branch table)
CREATE TABLE employee (
    employeeId      INT PRIMARY KEY AUTO_INCREMENT,
    branchId        INT NOT NULL,
    joiningDate     DATE NOT NULL,
    department      VARCHAR(50) NOT NULL,
    citizenID       VARCHAR(13) UNIQUE NOT NULL,
    firstName       VARCHAR(50) NOT NULL,
    lastName        VARCHAR(50) NOT NULL,
    dateOfBirth     DATE NOT NULL,
    phoneNumber     VARCHAR(20) NOT NULL,
    gender          CHAR(1) NOT NULL,
    position        VARCHAR(100) NOT NULL,
    salary          DECIMAL(12, 2),
    isFullTime      TINYINT(1) NOT NULL,

    CHECK (gender IN ('M', 'F')),
    FOREIGN KEY (branchId) REFERENCES branch(branchId)
);

-- Table: shift (references employee table)
CREATE TABLE shift (
    employeeId  INT NOT NULL,
    shift       VARCHAR(8) NOT NULL,

    PRIMARY KEY (employeeId, shift),
    FOREIGN KEY (employeeId) REFERENCES employee(employeeId),
    CHECK (shift IN ('morning', 'evening', 'night'))
);

-- Table: deliveryDriver (references employee table)
CREATE TABLE deliveryDriver (
    employeeId      INT PRIMARY KEY,
    licensePlate    NVARCHAR(20) NOT NULL,

    FOREIGN KEY (employeeId) REFERENCES employee(employeeId)
);

-- Table: operationZone (references employee table)
CREATE TABLE operationZone (
    employeeId      INT NOT NULL,
    operationZone   VARCHAR(50) NOT NULL,

    PRIMARY KEY (employeeId, operationZone),
    FOREIGN KEY (employeeId) REFERENCES deliveryDriver(employeeId)
);

-- Table: deliveryInformation
CREATE TABLE deliveryInformation (
    deliveryInformationId   INT PRIMARY KEY AUTO_INCREMENT,
    deliveredDate           DATE NOT NULL
);

-- Table: product
CREATE TABLE product (
    productId   INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    type        VARCHAR(50) NOT NULL,
    price       DECIMAL(12, 2) NOT NULL
);

-- Table: order (references user, branch, and deliveryInformation tables)
CREATE TABLE `order` (
    orderId                 INT PRIMARY KEY AUTO_INCREMENT,
    orderDate               DATETIME NOT NULL,
    userID                  INT NOT NULL,
    branchID                INT NOT NULL,
    deliveryInformationId   INT UNIQUE NOT NULL,

    FOREIGN KEY (userID) REFERENCES user(userId),
    FOREIGN KEY (branchID) REFERENCES branch(branchId),
    FOREIGN KEY (deliveryInformationId) REFERENCES deliveryInformation(deliveryInformationId)
);

-- Table: orderItem (references order and product tables)
CREATE TABLE orderItem (
    orderItemId INT NOT NULL,
    orderId     INT NOT NULL,
    productId   INT NOT NULL,
    quantity    INT NOT NULL,

    PRIMARY KEY (orderItemId, orderId, productId),
    FOREIGN KEY (orderId) REFERENCES `order`(orderId),
    FOREIGN KEY (productId) REFERENCES product(productId)
);

-- Table: coupon
CREATE TABLE coupon (
    couponId            INT PRIMARY KEY AUTO_INCREMENT,
    name                VARCHAR(50) NOT NULL,
    discountPercent     INT NOT NULL,
    orderId             INT,

    CHECK (discountPercent BETWEEN 0 AND 100),
    FOREIGN KEY (orderId) REFERENCES `order`(orderId)
);

-- Table: applicable_coupon (references order, coupon, and product tables)
CREATE TABLE applicable_coupon (
    couponId    INT NOT NULL,
    productId   INT NOT NULL,

    PRIMARY KEY (couponId, productId),
    FOREIGN KEY (couponId) REFERENCES coupon(couponId),
    FOREIGN KEY (productId) REFERENCES product(productId)
);

-- Table: payment (references order and product tables)
CREATE TABLE payment (
    paymentId               INT PRIMARY KEY AUTO_INCREMENT,
    paidUsing               VARCHAR(50) NOT NULL,
    transactionReference    VARCHAR(100) NOT NULL,
    paidAmount              DECIMAL(12, 2) NOT NULL,
    paymentDate             DATETIME NOT NULL,
    orderId                 INT UNIQUE NOT NULL,

    CHECK (paidUsing IN ('cash', 'credit card')),
    FOREIGN KEY (orderId) REFERENCES `order`(orderId)
);

-- Table: pickupDeliveryInformation (references deliveryInformation and branch tables)
CREATE TABLE pickupDeliveryInformation (
    deliveryInformationId   INT PRIMARY KEY,
    pickupTime              TIME NOT NULL,
    branchId                INT NOT NULL,

    FOREIGN KEY (deliveryInformationId) REFERENCES deliveryInformation(deliveryInformationId),
    FOREIGN KEY (branchId) REFERENCES branch(branchId)
);

-- Table: homeDeliveryInformation (references deliveryInformation, savedDeliveryAddress, and employee tables)
CREATE TABLE homeDeliveryInformation (
    deliveryInformationId   INT PRIMARY KEY,
    savedDeliveryAddressId  INT NOT NULL,
    deliveryTime            TIME NOT NULL,
    deliveryCharge          DECIMAL(12, 2) NOT NULL,
    employeeId              INT NOT NULL,

    FOREIGN KEY (deliveryInformationId) REFERENCES deliveryInformation(deliveryInformationId),
    FOREIGN KEY (savedDeliveryAddressId) REFERENCES savedDeliveryAddress(savedDeliveryAddressId),
    FOREIGN KEY (employeeId) REFERENCES deliveryDriver(employeeId)
);

INSERT INTO user (firstName,lastName,gender,dateOfBirth,phoneNumber,email,passwordHash,taxId,company,taxinformationAddress,postalCode)
VALUES
('Natchapol','Lebkrut','M','2003-06-30','0611111111','natchapol.lebkrut@db.com','$2b$12$CjP2UWnaD3s9QvHg/Mh.BulDQAi75.pgeu8jXZmoCQQaVRTieOjta',
'1111111111','SIIT','Khlong Luang District, Pathum Thani.','12120'),
('Vayuphak','Saengthong','M','2003-09-15','0622222222','vayuphak.saengthong@db.com','$2b$12$4QXcxxg/Iis0HD9nxMjsyOfuT9KbErEl5ulDlnfgZh9neGu9IwItq'
,'2222222222','Thai Japan Company Ltd.','Bangkok, Thailand','10110'),
('Napat', 'Decha', 'M', '2002-08-22','0633333333', 'napat.decha@db.com', '$2b$12$9MSuJdQ9zRbdrk5Dp9hKTO9Dylw69T1Cx/jErQ6.Siw.y4z3HvMte', 
'3333333333', 'False Corp.','Bangkok, Thailand','10500'),
('Napat', 'Tatiyakaroonwong', 'M', '2002-11-12','0644444444', 'napat.tatiya@db.com', '$2b$12$.Ln77qph1xM9IQEesFHDVeZl0cvVEdvIfBzmf7HVeR9bGsAlZkpxy', 
'4444444444', 'SIA Corp.','Bangkok, Thailand','10600'),
('Chatdanai', 'Wongsuwan', 'M', '2001-03-29','0655555555', 'chatdanai.wongsuwan@db.com', '$2b$12$e1pL7KtEAvIzqlyjzL7HUuuMLbcbRdPfQNkGDCq3bIRwdPio3YFz2', 
'5555555555', 'Thai German Company Ltd.','Khlong Luang District, Pathum Thani.','10400'),
('Haseeb','Ali','M','2003-07-04','0666666666','haseeb.ai@db.com','$2b$12$1wLlV5dcGvcWRcAqlRnVee.LKNW3.S23GkHcxybr10tcOGYvED0bu'
,NULL,NULL,NULL,NULL),
('Somsri', 'Hiran', 'F', '1995-05-10','0677777777', 'somsak.hiran@db.com', '$2b$12$Hpu4WjlxyT2lvTb/ceEjceH9Uih3jxn5Lkge0HGVEDdVbPCDpqH4e'
,NULL,NULL,NULL,NULL),
('Yingrat', 'Rattana', 'F', '1998-02-18','0688888888', 'yingrat.rattana@db.com', '$2b$12$9jsqZ23PIon45zctdOa5m.JYOa4DnEuV5QvHnFrFgKoIuEqGBzn0a'
,NULL,NULL,NULL,NULL),
('Itthirath', 'Jeamanukul', 'M', '2000-12-07','0699999999', 'itthirath.jeamanukul@db.com', '$2b$12$7G2OtsQxDCGYYfrqRdo85.fLLri1LsMW7qbfLl2SGjMb98ZPq4IK2'
,NULL,NULL,NULL,NULL),
('Pikul', 'Watdao', 'F', '1996-08-25','0612222222', 'pikul.watdao@db.com', '$2b$12$CCuI1IxDfT/E6.2Vf2fxzeXS.jh9zEMO/6UM/jR9w9EUZTytfZoFq'
,NULL,NULL,NULL,NULL);

INSERT INTO membership (userId, totalPoint, tierUpdateDate) VALUES
(1, 250, '2025-03-15'),
(2, 45, '2025-02-10'),
(3, 400, '2025-03-05'),
(4, 150, '2025-04-01'),
(5, 160, '2025-05-20'),
(6, 40, '2025-06-12'),
(7, 320, '2025-07-30'),
(8, 170, '2025-08-18'),
(9, 0, '2024-12-25'),
(10, 100, '2024-12-03');

INSERT INTO savedDeliveryAddress (phoneNumber, remarks, houseNumber, buildingNumber, mapAddress, addressLabel, userId) VALUES
('0611111111', NULL, '827', NULL, '3J94+HX4', 'Wangmai, Pathumwan, Bangkok 10330', 1),
('0611111111', 'close to Lotus', '940/1', 'B', '3J94+FJ3', 'Sam Sen Nok, Huai Khwang, Bangkok 10310', 1),
('0622222222', NULL, '141', NULL, '3J94+HQ2', 'Wangburapa, PraNaKorn, Bangkok 10200', 2),
('0633333333', NULL, '149', 'C', '3J94+H9V', 'Wangburapa, PraNaKorn, Bangkok 10200', 3),
('0644444444', 'next to BigC', '670', NULL, '3J94+M83', 'Ladyao, Jatujak, Bangkok 10900', 4),
('0655555555', NULL, '104', NULL, '3J94+Q2M', 'Bangkrasor, Muang, Nonthaburi 11000', 5),
('0666666666', 'Biggest House', '90', NULL, '3J94+5X4', 'Klongluang, Pathumthani 12120', 6),
('0677777777', NULL, '96', 'D', '3J94+6GG', 'Klong 1, Klongluang, Pathumthani 12120', 7),
('0688888888', 'close to toll way', '139', NULL, '3J94+HQW', 'Wangburapa, PraNaKorn, Bangkok 10200', 8),
('0699999999', NULL, '291/1', 'E', '3J94+HX4', 'Wangmai, Pathumwan, Bangkok 10330', 9),
('0612222222', 'next to the school', '393/9', 'F', '3J94+F3J', 'Sam Sen Nok, Huai Khwang, Bangkok 10310', 10),
('0611111111', NULL, '510', NULL, '3J94+FF9', 'Sam Sen Nok, Huai Khwang, Bangkok', 1),
('0611111111', 'next to the train station', '345', 'G', '3J94+H2V', 'Wangmai, Pathumwan, Bangkok 10330', 1),
('0633333333', NULL, '123', 'H', '3J94+QM7', 'Bangkrasor, Muang, Nonthaburi 11000', 3),
('0644444444', NULL, '829', NULL, '3J94+M83', 'Ladyao, Jatujak, Bangkok 10900', 4);


INSERT INTO branch (name, phoneNumber, houseNumber, subDistrict, district, province, openingTime, closingTime) VALUES
('Pizza Com Lotus Chareonpol Tesco Lotus Rama 1', '026126882', '831', 'Wangmai', 'Pathumwan', 'Bangkok', '09:00:00', '21:00:00'),
('Pizza Com Samyan Mitrtown', '0654541638', '944/1', 'Wangmai', 'Pathumwan', 'Bangkok', '10:00:00', '22:00:00'),
('Pizza Com Meng-Jai', '0614120318', '507-509', 'Sam  Sen Nok', 'Huai Khwang', 'Bangkok', '10:00:00', '24:00:00'),
('Pizza Com Ratchabophit', '0655076352', '148', 'Wangburapa', 'PraNaKorn', 'Bangkok', '08:00:00', '24:00:00'),
('Pizza Com Big C Ladprao', '029837398', '669', 'Ladyao', 'Jatujak', 'Bangkok', '10:00:00', '21:00:00'),
('Pizza Com Manor Sanambin-Nam', '0922810673', '102-103', 'Bangkrasor', 'Muang', 'Nonthaburi', '08:00:00', '22:00:00'),
('Pizza Com PTT Sribuathong', '0922810619', '46/21', 'Sono Loy', 'Bang Bua Thong', 'Nonthaburi', '08:00:00', '22:00:00'),
('Pizza Com Thummasart Rangsit', '0922810584', '95', 'Klong 1', 'Klongluang', 'Pathumthani', '09:00:00', '21:50:00'),
('Pizza Com Klongluang', '0922810725', '7/39-40', 'Klongsong', 'Klongluang', 'Pathumthani', '10:00:00', '24:00:00'),
('Pizza Com Rangsit Klong 10', '0922810600', '40/2', 'Buengsanan', 'Thanyaburi', 'Pathumthani', '09:00:00', '22:00:00');

INSERT INTO employee (branchId, joiningDate, department, citizenID, firstName, lastName, dateOfBirth, phoneNumber, gender, position, salary, isFullTime) VALUES
(1, '2017-03-10', 'Management', '4567890723457', 'Anan', 'Phongchai', '1995-02-28', '0612345673', 'M', 'Branch Manager', 35000.00, 1),
(1, '2020-05-10', 'Cooking', '1234567890173', 'Thanakorn', 'Srisuk', '1990-04-15', '0812345670', 'M', 'Pizza Baker', 25000.00, 1),
(1, '2023-01-20', 'Cashier', '3406789012346', 'Sirin', 'Kittithorn', '1985-12-05', '0812345672', 'F', 'Cashier', 15000.00, 1),
(1, '2023-02-25', 'Delivery', '5648901234568', 'Nipa', 'Wanich', '1988-11-14', '0812345674', 'F', 'Delivery Driver', 20000.00, 1),
(1, '2021-07-15', 'Delivery', '2745678901235', 'Nattapong', 'Boonmee', '1992-07-20', '0612345671', 'M', 'Delivery Driver', NULL, 0),
(2, '2017-11-05', 'Management', '9712345678903', 'Kanok', 'Phongpan', '1991-08-25', '0812345678', 'M', 'Branch Manager', 35000.00, 1),
(2, '2019-02-10', 'Cooking', '6789012345679', 'Somsak', 'Thammasak', '1993-09-22', '0612345675', 'M', 'Pizza Baker', 25000.00, 1),
(2, '2023-06-10', 'Cashier', '8971234567892', 'Preecha', 'Wiriyaporn', '1982-01-10', '0612345677', 'M', 'Cashier', 15000.00, 1),
(2, '2023-03-01', 'Delivery', '7123456789014', 'Saowaluk', 'Yamsri', '1989-03-12', '0612345679', 'F', 'Delivery Driver', 20000.00, 1),
(2, '2021-12-12', 'Delivery', '7890123456731', 'Thida', 'Sukjai', '1990-06-30', '0812345676', 'F', 'Delivery Driver', NULL, 0),
(3, '2017-04-10', 'Management', '4356789712348', 'Manas', 'Phutthachot', '1991-06-20', '0612345683', 'M', 'Branch Manager', 35000.00, 1),
(3, '2019-06-15', 'Cooking', '1723456789015', 'Wiroj', 'Suchat', '1987-05-16', '0812345680', 'M', 'Pizza Baker', 25000.00, 1),
(3, '2023-04-25', 'Cashier', '3245678971237', 'Weerachai', 'Phrompakdee', '1988-03-30', '0812345682', 'M', 'Cashier', 15000.00, 1),
(3, '2023-03-10', 'Delivery', '5467897123459', 'Kamol', 'Sriboon', '1994-09-22', '0812345684', 'M', 'Delivery Driver', 20000.00, 1),
(3, '2020-07-30', 'Delivery', '2134567897126', 'Patcharaporn', 'Nontaket', '1995-10-10', '0612345681', 'F', 'Delivery Driver', NULL, 0),
(4, '2016-01-25', 'Management', '9901234567893', 'Pornchai', 'Thammasak', '1995-02-14', '0812345688', 'M', 'Branch Manager', 35000.00, 1),
(4, '2018-10-12', 'Cooking', '6578901234560', 'Supaporn', 'Yokchai', '1986-08-30', '0612345685', 'F', 'Pizza Baker', 25000.00, 1),
(4, '2023-03-18', 'Cashier', '8790123456782', 'Narong', 'Tosapon', '1989-12-17', '0612345687', 'M', 'Cashier', 15000.00, 1),
(4, '2023-07-11', 'Delivery', '1112345678904', 'Ratchanee', 'Sungthong', '1990-11-11', '0612345689', 'F', 'Delivery Driver', 20000.00, 1),
(4, '2020-03-18', 'Delivery', '7689012345671', 'Suchada', 'Sutham', '1983-07-24', '0812345686', 'F', 'Delivery Driver', NULL, 0),
(5, '2017-02-05', 'Management', '2223456789015', 'Rungnapa', 'Chaisarn', '1985-01-02', '0812345690', 'F', 'Branch Manager', 35000.00, 1),
(5, '2019-09-01', 'Cooking', '3334567890126', 'Yuthana', 'Namwong', '1993-11-11', '0612345691', 'M', 'Pizza Baker', 25000.00, 1),
(5, '2023-01-15', 'Cashier', '4445678901237', 'Somchai', 'Kittipong', '1982-05-30', '0812345692', 'M', 'Cashier', 15000.00, 1),
(5, '2023-02-10', 'Delivery', '6667890123459', 'Rattana', 'Anantachai', '1986-02-10', '0812345694', 'F', 'Delivery Driver', 20000.00, 1),
(5, '2021-04-20', 'Delivery', '5556789012348', 'Udom', 'Jaiklang', '1990-08-18', '0612345693', 'M', 'Delivery Driver', NULL, 0),
(6, '2017-07-30', 'Management', '1123456789013', 'Chompoo', 'Rattanasuk', '1990-10-05', '0812345703', 'F', 'Branch Manager', 35000.00, 1),
(6, '2019-01-05', 'Cooking', '7778901234567', 'Wanchai', 'Prasert', '1984-12-20', '0812345700', 'M', 'Pizza Baker', 25000.00, 1),
(6, '2023-03-12', 'Cashier', '8889012345678', 'Anong', 'Pimkarn', '1991-03-25', '0812345701', 'F', 'Cashier', 15000.00, 1),
(6, '2023-03-22', 'Delivery', '2234567890124', 'Phirun', 'Chakrit', '1987-05-12', '0812345704', 'M', 'Delivery Driver', 20000.00, 1),
(6, '2023-06-08', 'Delivery', '9990123456789', 'Pakorn', 'Sukwattana', '1988-09-15', '0812345702', 'M', 'Delivery Driver', NULL, 0),
(7, '2017-09-10', 'Management', '3345678901235', 'Yingyai', 'Sudjai', '1989-08-24', '0812345705', 'F', 'Branch Manager', 35000.00, 1),
(7, '2020-05-25', 'Cooking', '5567890123457', 'Kasem', 'Sukthang', '1991-04-08', '0612345706', 'M', 'Pizza Baker', 25000.00, 1),
(7, '2023-01-03', 'Cashier', '6678901234561', 'Ritthikorn', 'Nakarach', '1992-09-17', '0812345707', 'M', 'Cashier', 15000.00, 1),
(7, '2023-08-20', 'Delivery', '3345678901237', 'Chaisiri', 'Chirawat', '1995-02-02', '0612345709', 'M', 'Delivery Driver', 20000.00, 1),
(7, '2021-06-30', 'Delivery', '2134567890123', 'Siriporn', 'Dhanabut', '1994-04-10', '0812345708', 'F', 'Delivery Driver', NULL, 0),
(8, '2017-08-24', 'Management', '8890123456780', 'Burin', 'Somjit', '1985-12-08', '0812345710', 'M', 'Branch Manager', 35000.00, 1),
(8, '2021-01-15', 'Cooking', '1112345678902', 'Kanlayanee', 'Pathawee', '1991-08-11', '0812345712', 'F', 'Pizza Baker', 25000.00, 1),
(8, '2023-11-05', 'Cashier', '9901234567897', 'Korn', 'Kritsana', '1994-02-14', '0812345711', 'M', 'Cashier', 15000.00, 1),
(8, '2023-07-27', 'Delivery', '3334567890124', 'Yuwadee', 'Niwat', '1992-11-25', '0812345714', 'F', 'Delivery Driver', 20000.00, 1),
(8, '2023-03-19', 'Delivery', '2223456789013', 'Pharanee', 'Jirasri', '1987-09-05', '0812345713', 'F', 'Delivery Driver', NULL, 0),
(9, '2017-10-15', 'Management', '4445678901235', 'Wut', 'Saengchan', '1988-01-30', '0812345715', 'M', 'Branch Manager', 35000.00, 1),
(9, '2020-05-16', 'Cooking', '6667890123457', 'Thitiporn', 'Sutthipong', '1989-04-13', '0812345717', 'F', 'Pizza Baker', 25000.00, 1),
(9, '2023-02-27', 'Cashier', '5556789012346', 'Kusuma', 'Wongthong', '1995-07-08', '0812345716', 'F', 'Cashier', 15000.00, 1),
(9, '2023-09-30', 'Delivery', '7778901234568', 'Chanchai', 'Tanasuk', '1984-06-21', '0812345718', 'M', 'Delivery Driver', 20000.00, 1),
(9, '2023-11-12', 'Delivery', '8889012345679', 'Noknoi', 'Pattana', '1990-08-19', '0812345719', 'F', 'Delivery Driver', NULL, 0),
(10, '2017-12-18', 'Management', '9990123456780', 'Prapai', 'Chayachote', '1987-03-11', '0812345720', 'F', 'Branch Manager', 35000.00, 1),
(10, '2020-08-14', 'Cooking', '2222345678902', 'Chinnakorn', 'Namchai', '1993-10-02', '0812345722', 'M', 'Pizza Baker', 25000.00, 1),
(10, '2023-04-01', 'Cashier', '1111234567891', 'Worachai', 'Phongpan', '1985-12-25', '0812345721', 'M', 'Cashier', 15000.00, 1),
(10, '2023-03-23', 'Delivery', '3333456789013', 'Siriporn', 'Jindaporn', '1992-04-18', '0812345723', 'F', 'Delivery Driver', 20000.00, 1),
(10, '2023-06-02', 'Delivery', '4444567890124', 'Phairoj', 'Thongdee', '1989-05-07', '0812345724', 'M', 'Delivery Driver', NULL, 0),
(1, '2023-11-15', 'Cashier', '5001234567890', 'Kittisak', 'Sittiporn', '1997-05-23', '0912345700', 'M', 'Cashier', 15000.00, 1),
(1, '2023-11-18', 'Cooking', '5002345678901', 'Narumon', 'Rattanasak', '1994-07-05', '0912345701', 'F', 'Pizza Baker', 25000.00, 1),
(2, '2023-11-12', 'Cashier', '6001234567890', 'Phatsara', 'Chaiyot', '1993-09-12', '0923456700', 'F', 'Cashier', 15000.00, 1),
(2, '2023-11-14', 'Cooking', '6002345678901', 'Wuttichai', 'Sukraw', '1995-11-18', '0923456701', 'M', 'Pizza Baker', 25000.00, 1),
(3, '2023-11-13', 'Cashier', '7001234567890', 'Nathawat', 'Srisai', '1998-02-03', '0934567800', 'M', 'Cashier', 15000.00, 1),
(3, '2023-11-16', 'Cooking', '7002345678901', 'Chanin', 'Rattanapong', '1996-03-19', '0934567801', 'F', 'Pizza Baker', 25000.00, 1),
(4, '2023-11-14', 'Cashier', '8001234567890', 'Kittipong', 'Wongthong', '1991-06-12', '0945678900', 'M', 'Cashier', 15000.00, 1),
(4, '2023-11-17', 'Cooking', '8002345678901', 'Pimnara', 'Mongkol', '1994-08-29', '0945678901', 'F', 'Pizza Baker', 25000.00, 1),
(5, '2023-11-12', 'Cashier', '9001234567890', 'Sutthira', 'Sukee', '1996-01-08', '0956789000', 'F', 'Cashier', 15000.00, 1),
(5, '2023-11-15', 'Cooking', '9002345678901', 'Jiratchaya', 'Sangthong', '1995-12-20', '0956789001', 'M', 'Pizza Baker', 25000.00, 1),
(6, '2023-11-10', 'Cashier', '1001234567890', 'Napatsorn', 'Chutintorn', '1994-04-25', '0967890100', 'F', 'Cashier', 15000.00, 1),
(6, '2023-11-13', 'Cooking', '1002345678901', 'Worraya', 'Tanatat', '1993-07-14', '0967890101', 'M', 'Pizza Baker', 25000.00, 1),
(7, '2023-11-13', 'Cashier', '1101234567890', 'Pimpisa', 'Suwanwat', '1992-09-07', '0978901230', 'F', 'Cashier', 15000.00, 1),
(7, '2023-11-16', 'Cooking', '1102345678901', 'Chalermpol', 'Kongkaew', '1995-05-22', '0978901231', 'M', 'Pizza Baker', 25000.00, 1),
(8, '2023-11-14', 'Cashier', '1201234567890', 'Kanokwan', 'Chongkittikul', '1997-02-05', '0989012340', 'F', 'Cashier', 15000.00, 1),
(8, '2023-11-18', 'Cooking', '1202345678901', 'Pongsakorn', 'Khachok', '1993-09-30', '0989012341', 'M', 'Pizza Baker', 25000.00, 1),
(9, '2023-11-10', 'Cashier', '1301234567890', 'Suwanit', 'Sathian', '1994-11-14', '0990123450', 'M', 'Cashier', 15000.00, 1),
(9, '2023-11-13', 'Cooking', '1302345678901', 'Nattapong', 'Sukkhaphirom', '1996-04-21', '0990123451', 'F', 'Pizza Baker', 25000.00, 1),
(10, '2023-11-12', 'Cashier', '1401234567890', 'Akkarawit', 'Suwannarat', '1995-09-02', '0901234560', 'M', 'Cashier', 15000.00, 1),
(10, '2023-11-15', 'Cooking', '1402345678901', 'Nuttapong', 'Chintana', '1994-12-10', '0901234561', 'F', 'Pizza Baker', 25000.00, 1);

INSERT INTO shift (employeeId, shift) VALUES
(1, 'morning'), (1, 'evening'),
(2, 'morning'), (2, 'evening'),
(3, 'morning'), (3, 'evening'), 
(4, 'morning'), (4, 'evening'),
(5, 'night'),
(6, 'morning'), (6, 'evening'),
(7, 'morning'), (7, 'evening'), 
(8, 'morning'), (8, 'evening'), 
(9, 'morning'), (9, 'evening'),
(10, 'night'),
(11, 'morning'), (11, 'evening'),
(12, 'morning'), (12, 'evening'),
(13, 'morning'), (13, 'evening'),
(14, 'morning'), (14, 'evening'),
(15, 'night'),
(16, 'morning'), (16, 'evening'),
(17, 'morning'), (17, 'evening'),
(18, 'morning'), (18, 'evening'),
(19, 'morning'), (19, 'evening'),
(20, 'night'),
(21, 'morning'), (21, 'evening'),
(22, 'morning'), (22, 'evening'), 
(23, 'morning'), (23, 'evening'), 
(24, 'morning'), (24, 'evening'),
(25, 'night'),
(26, 'morning'), (26, 'evening'),
(27, 'morning'), (27, 'evening'),
(28, 'morning'), (28, 'evening'),
(29, 'morning'), (29, 'evening'), 
(30, 'night'),
(31, 'morning'), (31, 'evening'),
(32, 'morning'), (32, 'evening'), 
(33, 'morning'), (33, 'evening'), 
(34, 'morning'), (34, 'evening'),
(35, 'night'),
(36, 'morning'), (36, 'evening'),
(37, 'morning'), (37, 'evening'),
(38, 'morning'), (38, 'evening'),
(39, 'morning'), (39, 'evening'),
(40, 'night'),
(41, 'morning'), (41, 'evening'),
(42, 'morning'), (42, 'evening'),
(43, 'morning'), (43, 'evening'),
(44, 'morning'), (44, 'evening'),
(45, 'night'),
(46, 'morning'), (46, 'evening'),
(47, 'morning'), (47, 'evening'),
(48, 'morning'), (48, 'evening'), 
(49, 'morning'), (49, 'evening'),
(50, 'night'),
(51, 'night'),
(52, 'night'),
(53, 'night'),
(54, 'night'),
(55, 'night'),
(56, 'night'),
(57, 'night'),
(58, 'night'),
(59, 'night'),
(60, 'night');

INSERT INTO deliveryDriver (employeeId, licensePlate) VALUES
(4, 'กข1234 กรุงเทพมหานคร'),
(5, 'คง5678 ชลบุรี'),
(9, 'จฉ9012 นครราชสีมา'),
(10, 'ฉท3456 ภูเก็ต'),
(14, 'ชพ7890 เชียงใหม่'),
(15, 'ซอ1234 ขอนแก่น'),
(19, 'ฒญ5678 สระบุรี'),
(20, 'ณฑ9012 นครปฐม'),
(24, 'ดบ3456 ปทุมธานี'),
(25, 'ตจ7890 นนทบุรี'),
(29, 'ทม1234 สุพรรณบุรี'),
(30, 'ธบ5678 ระยอง'),
(34, 'นย9012 อยุธยา'),
(35, 'บค3456 สมุทรปราการ'),
(39, 'ปจ7890 สงขลา'),
(40, 'ฝช1234 สุราษฎร์ธานี'),
(44, 'พธ5678 อุบลราชธานี'),
(45, 'ฟน9012 พิษณุโลก'),
(49, 'มป3456 บุรีรัมย์'),
(50, 'ยธ7890 เลย');

INSERT INTO operationZone (employeeId, operationZone) VALUES
(4, 'Wangmai'),
(5, 'Wangmai'),
(5, 'Pathumwan'),
(9, 'Pathumwan'),
(10, 'Pathumwan'),
(14, 'Sam Sen Nok'),
(15, 'Sam Sen Nok'),
(15, 'Sam Sen Nai'),
(19, 'Wangburapa'),
(20, 'Wangburapa'),
(24, 'Ladyao'),
(25, 'Ladyao'),
(25, 'Bang Khen'),
(29, 'Bangkrasor'),
(30, 'Bangkrasor'),
(34, 'Sono Loy'),
(35, 'Sono Loy'),
(39, 'Klong nueng'),
(40, 'Klong nueung '),
(40, 'Klong song'),
(44, 'Klong song'),
(45, 'Klong song'),
(45, 'Klong nueng'),
(49, 'Buengsanan'),
(50, 'Buengsanan');

INSERT INTO deliveryInformation (deliveredDate) VALUES
('2024-11-01'),
('2024-11-01'),
('2024-11-01'),
('2024-11-02'),
('2024-11-02'),
('2024-11-02'),
('2024-11-03'),
('2024-11-03'),
('2024-11-03'),
('2024-11-04'),
('2024-11-04'),
('2024-11-04'),
('2024-11-05'),
('2024-11-05'),
('2024-11-05'),
('2024-11-06'),
('2024-11-06'),
('2024-11-06'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07'),
('2024-11-07');

INSERT INTO product(name,type,price) VALUES
('doble cheese','pizza',419.00),
('doble pepperoni','pizza',419.00),
('crazy cheesy','bite',129.00),
('the bite box setA','set for one',119.00),
('korean style chicken wings','chicken',149.00),
('stir fried macaroni ham and omelet','pasta',129.00),
('french fries','appetizer',69.00),
('caesar salad','salad',99.00),
('pork chop steak with garlic bread','steak',219.00),
('coke','drink',45.00),
('hawaiian delight', 'pizza', 419.00),
('seafood supreme', 'pizza', 459.00),
('mushroom melt', 'pizza', 399.00),
('spicy seafood combo', 'bite', 149.00),
('the bite box set B', 'set for one', 149.00),
('honey bbq chicken wings', 'chicken', 159.00),
('carbonara spaghetti', 'pasta', 149.00),
('crispy chicken strips', 'appetizer', 89.00),
('garden fresh salad', 'salad', 99.00),
('grilled salmon with rice', 'steak', 259.00),
('orange juice', 'drink', 49.00),
('bbq chicken pizza', 'pizza', 429.00),
('bacon explosion', 'pizza', 439.00),
('cheesy bites', 'bite', 139.00),
('the super bite box set A', 'set for one', 169.00),
('spicy korean chicken wings', 'chicken', 169.00),
('spaghetti bolognese', 'pasta', 139.00),
('garlic breadsticks', 'appetizer', 59.00),
('tuna salad', 'salad', 109.00),
('grilled ribeye steak', 'steak', 299.00),
('iced lemon tea', 'drink', 45.00),
('pepperoni lovers', 'pizza', 419.00),
('margherita classic', 'pizza', 389.00),
('crispy cheese sticks', 'bite', 129.00),
('the bite box set C', 'set for one', 149.00),
('garlic parmesan chicken wings', 'chicken', 159.00),
('pesto pasta with chicken', 'pasta', 149.00),
('mozzarella sticks', 'appetizer', 79.00),
('chef’s salad', 'salad', 119.00),
('sirloin steak with mashed potatoes', 'steak', 289.00);

INSERT INTO `order` (orderDate, userID, branchID, deliveryInformationId) VALUES
('2024-11-01 10:03:17', 1, 1, 1),
('2024-11-01 11:22:05', 2, 2, 2),
('2024-11-01 19:48:31', 3, 3, 3),
('2024-11-02 21:10:44', 4, 4, 4), 
('2024-11-02 09:28:57', 5, 5, 5),
('2024-11-02 16:03:22', 6, 6, 6),
('2024-11-03 12:36:41', 7, 7, 7),
('2024-11-03 13:11:58', 8, 8, 8),
('2024-11-03 20:15:10', 9, 9, 9),
('2024-11-04 14:32:11', 10, 10, 10),
('2024-11-04 11:07:14', 1, 1, 11),
('2024-11-04 13:23:47', 2, 2, 12),
('2024-11-05 15:12:05', 3, 3, 13),
('2024-11-05 10:39:49', 4, 4, 14),
('2024-11-05 16:35:42', 5, 5, 15),
('2024-11-06 14:00:17', 6, 6, 16),
('2024-11-06 12:15:23', 7, 7, 17),
('2024-11-06 10:30:42', 8, 8, 18),
('2024-11-07 09:45:13', 9, 9, 19),
('2024-11-07 13:00:29', 10, 10, 20),
('2024-11-07 11:30:07', 1, 1, 21),
('2024-11-07 15:00:53', 2, 2, 22),
('2024-11-07 22:00:18', 3, 3, 23),
('2024-11-07 20:30:09', 4, 4, 24),
('2024-11-07 14:30:33', 5, 5, 25),
('2024-11-07 16:00:45', 6, 6, 26),
('2024-11-07 13:30:11', 7, 7, 27),
('2024-11-07 10:45:27', 8, 8, 28),
('2024-11-07 12:00:32', 9, 9, 29),
('2024-11-07 14:15:19', 10, 10, 30);


INSERT INTO orderItem (orderId, orderItemId, productId, quantity) VALUES
(1, 1, 5, 3),
(1, 2, 15, 2),
(1, 3, 22, 1),
(2, 1, 9, 4),
(2, 2, 13, 2),
(2, 3, 27, 3),
(3, 1, 7, 1),
(3, 2, 18, 2),
(3, 3, 3, 5),
(4, 1, 12, 4),
(4, 2, 19, 3),
(4, 3, 25, 2),
(5, 1, 30, 1),
(5, 2, 10, 4),
(5, 3, 6, 5),
(6, 1, 16, 2),
(6, 2, 24, 3),
(6, 3, 1, 4),
(7, 1, 11, 2),
(7, 2, 8, 3),
(7, 3, 20, 1),
(8, 1, 28, 5),
(8, 2, 4, 2),
(8, 3, 2, 4),
(9, 1, 17, 3),
(9, 2, 23, 2),
(9, 3, 29, 1),
(10, 1, 21, 4),
(10, 2, 14, 3),
(10, 3, 26, 2),
(11, 1, 18, 3),
(11, 2, 27, 2),
(11, 3, 13, 5),
(12, 1, 25, 1),
(12, 2, 12, 4),
(12, 3, 5, 3),
(13, 1, 30, 2),
(13, 2, 6, 4),
(13, 3, 15, 1),
(14, 1, 3, 3),
(14, 2, 9, 2),
(14, 3, 7, 5),
(15, 1, 19, 4),
(15, 2, 4, 1),
(15, 3, 14, 3),
(16, 1, 22, 2),
(16, 2, 10, 5),
(16, 3, 8, 3),
(17, 1, 26, 3),
(17, 2, 23, 1),
(17, 3, 12, 4),
(18, 1, 5, 4),
(18, 2, 20, 3),
(18, 3, 27, 2),
(19, 1, 8, 1),
(19, 2, 16, 5),
(19, 3, 3, 4),
(20, 1, 6, 3),
(20, 2, 30, 2),
(20, 3, 1, 4),
(21, 1, 7, 5),
(21, 2, 11, 3),
(21, 3, 17, 2),
(22, 1, 12, 4),
(22, 2, 14, 1),
(22, 3, 18, 3),
(23, 1, 29, 2),
(23, 2, 9, 3),
(23, 3, 20, 5),
(24, 1, 4, 3),
(24, 2, 5, 2),
(24, 3, 30, 1),
(25, 1, 19, 4),
(25, 2, 8, 1),
(25, 3, 22, 3),
(26, 1, 2, 2),
(26, 2, 27, 5),
(26, 3, 25, 3),
(27, 1, 17, 1),
(27, 2, 18, 3),
(27, 3, 3, 4),
(28, 1, 28, 2),
(28, 2, 10, 4),
(28, 3, 13, 3),
(29, 1, 21, 5),
(29, 2, 30, 3),
(29, 3, 6, 2),
(30, 1, 16, 4),
(30, 2, 9, 1),
(30, 3, 24, 5);

INSERT INTO coupon (name, discountPercent, orderId) VALUES
('Discount10', 10, 1),
('Holiday20', 20, 2),
('Summer15', 15, 3),
('Winter25', 25, 4),
('Promo5', 5, 5),
('Festive30', 30, 6),
('BlackFriday40', 40, 7),
('NewYear50', 50, 8),
('Easter15', 15, 9),
('Christmas25', 25, 10),
('FlashSale30', 30, 11),
('VIPCustomer20', 20, 12),
('Clearance10', 10, 13),
('ExclusiveOffer20', 20, 14),
('EarlyBird10', 10, 15),
('SuperSale50', 50, 11),
('SuperCustomer90', 90, NULL);

INSERT INTO applicable_coupon (couponId, productId) VALUES
(1, 5),
(2, 13),
(3, 18),
(4, 25),
(5, 30),
(6, 16),
(7, 20),
(8, 2),
(9, 23),
(10, 21),
(11, 27),
(12, 12),
(13, 15),
(14, 7),
(15, 4),
(16, 13),
(17, 1),
(17, 2);

INSERT INTO `payment` (paidUsing, transactionReference, paidAmount, paymentDate, orderId) VALUES
('credit card', 'TXN-4829176542', 1129.30, '2024-11-01 10:11:36', 1),
('credit card', 'TXN-1739456201', 1931.40, '2024-11-01 11:36:30', 2),
('credit card', 'TXN-3956217480', 865.30, '2024-11-01 20:05:13', 3),
('cash', 'TXN-4862173950', 2386.5, '2024-11-02 21:35:12', 4),
('credit card', 'TXN-5028341792', 1109.05, '2024-11-02 09:45:33', 5),
('cash', 'TXN-6192837450', 2315.60, '2024-11-02 16:24:50', 6),
('cash', 'TXN-7263194805', 1290.40, '2024-11-03 12:48:02', 7),
('cash', 'TXN-8321746593', 1371.00, '2024-11-03 13:28:41', 8),
('credit card', 'TXN-9317264085', 1302.30, '2024-11-03 20:41:37', 9),
('cash', 'TXN-0418263957', 932.00, '2024-11-04 14:47:56', 10),
('credit card', 'TXN-1592837465', 1459.10, '2024-11-04 11:21:09', 11),
('cash', 'TXN-2683741590', 2084.80, '2024-11-04 13:46:33', 12),
('credit card', 'TXN-3472815906', 1248.10, '2024-11-05 15:31:19', 13),
('cash', 'TXN-4738201659', 1101.00, '2024-11-05 11:08:21', 14),
('cash', 'TXN-5817264903', 950.10, '2024-11-05 16:56:07', 15),
('cash', 'TXN-6928374150', 1380.00, '2024-11-06 14:13:38', 16),
('credit card', 'TXN-7319504826', 2782.00, '2024-11-06 12:33:23', 17),
('cash', 'TXN-8091762543', 1651.00, '2024-11-06 10:42:36', 18),
('credit card', 'TXN-9031654827', 1410.00, '2024-11-07 09:59:42', 19),
('credit card', 'TXN-1572938462', 2661, '2024-11-07 13:15:45', 20),
('credit card', 'TXN-2654718392', 1900.00, '2024-11-07 11:54:19', 21),
('cash', 'TXN-3816542790', 2252.00, '2024-11-07 15:29:14', 22),
('credit card', 'TXN-4928371506', 2170.00, '2024-11-07 22:21:08', 23),
('cash', 'TXN-5039284176', 954.00, '2024-11-07 20:46:11', 24),
('credit card', 'TXN-6172935804', 1782.00, '2024-11-07 14:54:46', 25),
('cash', 'TXN-7283059416', 2040.00, '2024-11-07 16:12:53', 26),
('credit card', 'TXN-8361742905', 932.00, '2024-11-07 13:45:09', 27),
('cash', 'TXN-9173062548', 1495.00, '2024-11-07 10:53:54', 28),
('credit card', 'TXN-0248175936', 1400.00, '2024-11-07 12:29:32', 29),
('cash', 'TXN-1593740286', 1550.00, '2024-11-07 14:38:43', 30);

INSERT INTO pickupDeliveryInformation (deliveryInformationId, pickupTime, branchId) VALUES
(1, '10:28:54', 1),
(2, '12:01:17', 2),
(3, '20:40:18', 3),
(4, '22:18:39', 4),
(5, '10:16:02', 5),
(6, '17:21:55', 6),
(7, '13:22:07', 7),
(8, '14:19:48', 8),
(9, '21:23:41', 9),
(10, '15:31:46', 10),
(11, '12:03:55', 1),
(12, '15:14:19', 2),
(13, '16:07:02', 3),
(14, '12:14:29', 4),
(15, '17:45:35', 5);

INSERT INTO homeDeliveryInformation (deliveryInformationId, savedDeliveryAddressId, deliveryTime, deliveryCharge, employeeId) VALUES
(16, 1, '14:30:18', 150.00, 29),
(17, 2, '12:47:36', 180.00, 34),
(18, 3, '11:02:59', 200.00, 39),
(19, 4, '10:16:27', 160.00, 44),
(20, 5, '13:43:16', 220.00, 49),
(21, 6, '12:05:39', 250.00, 4),
(22, 7, '15:45:28', 140.00, 9),
(23, 8, '22:50:08', 210.00, 15),
(24, 9, '21:06:52', 190.00, 20),
(25, 10, '15:17:46', 230.00, 24),
(26, 11, '16:39:59', 160.00, 29),
(27, 12, '14:13:04', 180.00, 34),
(28, 13, '11:21:41', 210.00, 39),
(29, 14, '12:58:19', 170.00, 44),
(30, 15, '15:07:56', 200.00, 49);