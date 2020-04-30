-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-04-2020 a las 00:16:55
-- Versión del servidor: 10.1.26-MariaDB
-- Versión de PHP: 7.1.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `platanera`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarBolsero` (IN `Id_b` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_b` INT)  NO SQL
UPDATE `bolseros` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM, `Tipo`=Tipo_b WHERE id = Id_b$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPelador` (IN `id_p` INT, IN `Nombre_p` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_p` INT)  NO SQL
UPDATE peladores SET nombre=Nombre_p, Ap_p= ApP, Ap_M= ApM, Tipo= Tipo_p where id=id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPro` (IN `Id_pro` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
UPDATE `productores` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM
WHERE id = Id_pro$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addBolsero` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `bolseros`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) VALUES (Nom, ApP, ApM, Tip)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmbarque` (IN `id_e` INT, IN `fecha_i` DATE)  NO SQL
BEGIN
insert into embarque (id, fecha_inicio, fecha_fin, cant_bolsas_embarque, no_sello, no_bolsas, placa) VALUES (id_e, fecha_i, '', 0, '', 0, '');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPelador` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `peladores`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) 
VALUES (Nom, ApP, ApM, Tip)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addProductores` (IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
INSERT INTO `productores`(`nombre`, `Ap_p`, `Ap_m`)
VALUES (Nombre, ApP, ApM)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteBolsero` (IN `id_b` INT)  NO SQL
DELETE from bolseros where id= id_b$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePelador` (IN `Id_p` INT)  NO SQL
DELETE FROM `peladores` WHERE id = Id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProd` (IN `Id_p` INT)  NO SQL
DELETE from productores WHERE id = Id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmb` (IN `id_e` INT)  NO SQL
SELECT `id`, `fecha_inicio`, `dia_actual`, `A`, `B`, `C`, `D`, `E`, `F`, `G`, `H`, `fecha_fin`, `cant_bolsas_embarque`, `no_sello`, `no_bolsas`, `placa` FROM `embarque` WHERE id =id_e$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmbarque` ()  NO SQL
SELECT id, fecha_inicio, cant_bolsas_embarque FROM embarque WHERE fecha_fin='0000-00-00' ORDER BY id ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaB` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGBolseros` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGPeladores` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaOProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m` FROM `productores` ORDER BY nombre$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaP` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m` FROM `productores`$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_bolsero`
--

CREATE TABLE `bolsas_bolsero` (
  `id` int(11) NOT NULL,
  `id_bolsero` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha_trabajo_bol` date NOT NULL,
  `cantidad_bolsas_bol` int(11) NOT NULL,
  `pago_bol` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas_bolsero`
--

INSERT INTO `bolsas_bolsero` (`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `cantidad_bolsas_bol`, `pago_bol`) VALUES
(1, 4, 5, '2020-04-12', 7, 70);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_pelador`
--

CREATE TABLE `bolsas_pelador` (
  `id` int(11) NOT NULL,
  `id_pelador` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha_trabajo_pe` date NOT NULL,
  `cantidad_bolsas_pe` int(11) NOT NULL,
  `pago_pe` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas_pelador`
--

INSERT INTO `bolsas_pelador` (`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`) VALUES
(1, 11, 2, '2020-04-11', 0, 0),
(2, 11, 3, '2020-04-11', 0, 0),
(3, 19, 5, '2020-04-12', 4, 40),
(4, 11, 5, '2020-04-12', 1, 10),
(5, 31, 5, '2020-04-12', 1, 10),
(6, 62, 5, '2020-04-12', 1, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolseros`
--

CREATE TABLE `bolseros` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `Ap_p` varchar(200) NOT NULL,
  `Ap_m` varchar(255) NOT NULL,
  `Tipo` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolseros`
--

INSERT INTO `bolseros` (`id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo`) VALUES
(4, 'JUAN', 'DOMINGUEZ', 'PEREZ', 2),
(5, 'EJEMPLO', 'DE', 'BOLSERO', 2),
(7, 'ADAN', 'ESCOBAR', 'R', 2),
(8, 'JUAN CAMILO', 'ROMERO', 'PEREZ', 2),
(10, 'Jared', 'Calderon', 'Garrison', 2),
(11, 'Yoshio', 'Green', 'Gardner', 2),
(12, 'Jemima', 'Mann', 'House', 2),
(13, 'Harding', 'Grimes', 'Becker', 2),
(14, 'Hu', 'Johnston', 'Short', 2),
(15, 'Glenna', 'Barlow', 'Mckay', 2),
(16, 'Deanna', 'Neal', 'Browning', 2),
(17, 'Vivien', 'Little', 'Allison', 2),
(18, 'Brianna', 'Fisher', 'Christensen', 2),
(19, 'Chaim', 'Pacheco', 'Doyle', 2),
(20, 'Neil', 'White', 'Long', 2),
(21, 'Ocean', 'Zimmerman', 'Gould', 2),
(22, 'Alana', 'Hood', 'Tyson', 2),
(23, 'Jasper', 'Jarvis', 'Henson', 2),
(24, 'Asher', 'Crawford', 'Griffin', 2),
(25, 'Francis', 'Beach', 'Bryan', 2),
(26, 'Elmo', 'Mckee', 'Crosby', 2),
(27, 'Boris', 'Haynes', 'Sawyer', 2),
(28, 'Jamal', 'Beard', 'Mcleod', 2),
(29, 'Tatyana', 'Clements', 'Combs', 2),
(30, 'Bruce', 'Salazar', 'Andrews', 2),
(31, 'Jemima', 'Leblanc', 'Robinson', 2),
(32, 'Quemby', 'Howe', 'Torres', 2),
(33, 'Martina', 'Burns', 'Mosley', 2),
(34, 'Ulric', 'Vargas', 'Fitzgerald', 2),
(35, 'Stephen', 'Hoffman', 'Black', 2),
(36, 'Alvin', 'Poole', 'Buchanan', 2),
(37, 'Raphael', 'Lamb', 'Bray', 2),
(38, 'Indira', 'Levy', 'Prince', 2),
(39, 'Sophia', 'Simpson', 'Bartlett', 2),
(40, 'Halla', 'Gregory', 'Thornton', 2),
(41, 'Dale', 'Singleton', 'Hammond', 2),
(42, 'Jaquelyn', 'Langley', 'Freeman', 2),
(43, 'Tarik', 'Hayes', 'Drake', 2),
(44, 'Brennan', 'Wiggins', 'Watts', 2),
(45, 'Alice', 'Osborn', 'Weber', 2),
(46, 'Idola', 'Blackburn', 'Ballard', 2),
(47, 'Caesar', 'Hart', 'Leblanc', 2),
(48, 'Gary', 'Bowen', 'Brock', 2),
(49, 'Cheyenne', 'Mueller', 'Wright', 2),
(50, 'Hedley', 'Dickson', 'Hester', 2),
(51, 'Sierra', 'Mclaughlin', 'Sutton', 2),
(52, 'Colt', 'Anderson', 'Martin', 2),
(53, 'Talon', 'Clayton', 'Contreras', 2),
(54, 'Mufutau', 'Mcneil', 'Cote', 2),
(55, 'Ciaran', 'Shields', 'Conner', 2),
(56, 'April', 'Hernandez', 'Fulton', 2),
(57, 'Devin', 'Rivera', 'Gibbs', 2),
(58, 'Edward', 'Sharpe', 'Washington', 2),
(59, 'Dawn', 'Diaz', 'Larson', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `embarque`
--

CREATE TABLE `embarque` (
  `id` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `dia_actual` int(2) NOT NULL,
  `A` date DEFAULT NULL,
  `B` date DEFAULT NULL,
  `C` date DEFAULT NULL,
  `D` date DEFAULT NULL,
  `E` date DEFAULT NULL,
  `F` date DEFAULT NULL,
  `G` date DEFAULT NULL,
  `H` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `cant_bolsas_embarque` int(10) DEFAULT NULL,
  `no_sello` varchar(10) DEFAULT NULL,
  `no_bolsas` int(11) DEFAULT NULL,
  `placa` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `embarque`
--

INSERT INTO `embarque` (`id`, `fecha_inicio`, `dia_actual`, `A`, `B`, `C`, `D`, `E`, `F`, `G`, `H`, `fecha_fin`, `cant_bolsas_embarque`, `no_sello`, `no_bolsas`, `placa`) VALUES
(1, '2020-03-05', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-04-06', 10, '1', 10, 'PLACA01'),
(2, '2020-04-05', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-04-13', 100, '', 0, ''),
(3, '2020-04-06', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-04-13', 123, '', 0, ''),
(4, '2020-04-06', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-04-13', 20, '', 0, ''),
(5, '2020-04-12', 1, '2020-04-12', '2020-04-13', '2020-04-14', '2020-04-15', '2020-04-16', NULL, NULL, NULL, '2020-04-12', 7, '12345', 0, '987456');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `extra`
--

CREATE TABLE `extra` (
  `id` int(11) NOT NULL,
  `id_pelador` int(11) DEFAULT NULL,
  `id_bolsero` int(11) DEFAULT NULL,
  `descripcion` varchar(255) NOT NULL,
  `pago` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `fruta`
--

CREATE TABLE `fruta` (
  `id` int(11) NOT NULL,
  `id_fruta` int(3) NOT NULL,
  `id_productores` int(11) NOT NULL,
  `peso_kg` float NOT NULL,
  `pago` float NOT NULL,
  `fecha_compra` date DEFAULT NULL,
  `cant_bolsas` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `dia_letra` varchar(255) NOT NULL,
  `foto_fruta` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `fruta`
--

INSERT INTO `fruta` (`id`, `id_fruta`, `id_productores`, `peso_kg`, `pago`, `fecha_compra`, `cant_bolsas`, `id_embarque`, `dia_letra`, `foto_fruta`) VALUES
(1, 1, 2, 70, 1000, '0000-00-00', 0, 2, '', ''),
(2, 2, 57, 70, 70, '0000-00-00', 0, 2, '', ''),
(3, 3, 3, 25, 25, '0000-00-00', 0, 2, '', ''),
(4, 4, 3, 4000, 12000, '0000-00-00', 0, 2, '', ''),
(7, 1, 42, 7000, 21000, '0000-00-00', 0, 3, '', ''),
(13, 1, 9, 2000, 8000, '2020-04-12', 0, 5, '', ''),
(14, 2, 3, 1000, 4000, '2020-04-12', 0, 5, '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `peladores`
--

CREATE TABLE `peladores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(11) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) NOT NULL,
  `Tipo` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `peladores`
--

INSERT INTO `peladores` (`id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo`) VALUES
(11, 'ALEJANDRA', 'LOPEZ', 'CERVERA', 1),
(12, 'ADAN', 'ESCOBAR', 'RAMIREZ', 1),
(17, 'LURA', 'JIMENEZ', 'VILLEGAS', 1),
(19, 'ADAN', 'ESCOBAR', 'R', 1),
(20, 'Hayden', 'Holden', 'Nieves', 1),
(21, 'Davis', 'Oneil', 'Dickerson', 1),
(22, 'Ira', 'Woodward', 'Bonner', 1),
(23, 'Meghan', 'Elliott', 'Michael', 1),
(24, 'Leah', 'Pearson', 'Vasquez', 1),
(25, 'Ocean', 'Elliott', 'Francis', 1),
(26, 'Abra', 'Tillman', 'Mayo', 1),
(27, 'Gregory', 'Zamora', 'Carey', 1),
(28, 'Heidi', 'Clay', 'Cobb', 1),
(29, 'Laith', 'Steele', 'Castillo', 1),
(30, 'Christine', 'Wright', 'Hinton', 1),
(31, 'Dacey', 'Acevedo', 'Rodriguez', 1),
(32, 'Zoe', 'Contreras', 'Gallagher', 1),
(33, 'Zachery', 'Clarke', 'Alston', 1),
(34, 'Ira', 'Stafford', 'Page', 1),
(35, 'Patrick', 'Camacho', 'Grimes', 1),
(36, 'Clark', 'Snyder', 'Perkins', 1),
(37, 'Damian', 'Bonner', 'Walton', 1),
(38, 'Knox', 'Fitzgerald', 'Bowers', 1),
(39, 'Baxter', 'Boone', 'Spencer', 1),
(40, 'Jordan', 'Montgomery', 'Ballard', 1),
(41, 'Nasim', 'Kaufman', 'Strong', 1),
(42, 'Shad', 'Thornton', 'Dyer', 1),
(43, 'Austin', 'Craig', 'Shannon', 1),
(44, 'Price', 'Camacho', 'Huber', 1),
(45, 'Bell', 'Head', 'Odom', 1),
(46, 'Stella', 'Crane', 'Riley', 1),
(47, 'Linda', 'Walter', 'Gomez', 1),
(48, 'Erich', 'Stewart', 'Good', 1),
(49, 'Sydnee', 'Blake', 'Ramirez', 1),
(50, 'Cathleen', 'Herring', 'Nicholson', 1),
(51, 'Aileen', 'Randall', 'Mercer', 1),
(52, 'Cheyenne', 'Mooney', 'Guy', 1),
(53, 'Brian', 'Solis', 'Vang', 1),
(54, 'Maggy', 'Cummings', 'Morrison', 1),
(55, 'Bryar', 'Greer', 'Adams', 1),
(56, 'Berk', 'Haley', 'Castillo', 1),
(57, 'Hiram', 'Delacruz', 'Sanford', 1),
(58, 'Nasim', 'Good', 'Haynes', 1),
(59, 'Vanna', 'Cole', 'Mercado', 1),
(60, 'Quail', 'Contreras', 'Kirby', 1),
(61, 'Brett', 'Rutledge', 'Guzman', 1),
(62, 'Mara', 'Santana', 'Ferguson', 1),
(63, 'Channing', 'Bender', 'Roach', 1),
(64, 'Anika', 'Andrews', 'Reyes', 1),
(65, 'Ezra', 'Monroe', 'Holman', 1),
(66, 'Fritz', 'Cortez', 'Alford', 1),
(67, 'Harlan', 'Medina', 'Matthews', 1),
(68, 'Rebekah', 'Justice', 'Barrera', 1),
(69, 'Willow', 'Mason', 'Sims', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productores`
--

CREATE TABLE `productores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `productores`
--

INSERT INTO `productores` (`id`, `nombre`, `Ap_p`, `Ap_m`) VALUES
(1, 'ALE', 'LOPEZ', 'CERVERA'),
(2, 'ALBERT', 'RAMOS', 'GONZALEZ'),
(3, 'ADAN', 'ESCOBAR', 'R'),
(5, 'EJEMPLO', 'EXAMPLE', 'RAMZ'),
(6, 'JUAN', 'LUNA', 'DOMINGUEZ'),
(7, 'LEONARDO', 'GUTIERREZ', 'MENDOSA'),
(8, 'ALBERT', 'RAMOS', 'GONZALEZ'),
(9, 'ADAN', 'ESCOBAR', 'RASDAS'),
(16, 'JUAN', 'LUNA', 'DOMINGUEZ'),
(17, 'LEONARDO', 'GUTIERREZ', 'MENDOSA'),
(18, 'CAMILA', 'RAMIREZ', 'CAMPOS'),
(19, 'MIRANDA', 'JIMENEZ', 'CRUZ'),
(20, 'DANIEL', 'LUNA', 'PEREZ'),
(21, 'LUIS', 'RAMOS', 'CERVERA'),
(22, 'CAMILA', 'RAMIREZ', 'CAMPOS'),
(23, 'MIRANDA', 'JIMENEZ', 'CRUZ'),
(24, 'DANIEL', 'LUNA', 'PEREZ'),
(25, 'luis', 'ramos', 'cervera'),
(26, 'Graiden', 'Benson', 'Love'),
(27, 'Walker', 'Craft', 'Holden'),
(28, 'Rowan', 'Spence', 'Levy'),
(29, 'Claire', 'Mckay', 'Turner'),
(30, 'Martina', 'Pittman', 'Clemons'),
(31, 'Galvin', 'Nielsen', 'Mccarty'),
(32, 'Uma', 'Nguyen', 'Pate'),
(33, 'Kiayada', 'Rosa', 'Avery'),
(34, 'Nevada', 'Carrillo', 'Hudson'),
(35, 'Stacey', 'Barr', 'Keith'),
(36, 'Cailin', 'Grant', 'Page'),
(37, 'Tashya', 'Franks', 'Cantu'),
(38, 'Stella', 'Skinner', 'Oneil'),
(39, 'Jasper', 'Padilla', 'Thornton'),
(40, 'Unity', 'Dudley', 'Cardenas'),
(41, 'Leilani', 'Pope', 'Hayes'),
(42, 'Alana', 'Guerrero', 'Warren'),
(43, 'Velma', 'Small', 'Webster'),
(44, 'Elaine', 'Heath', 'Neal'),
(45, 'Juliet', 'Hancock', 'Justice'),
(46, 'Harper', 'Rollins', 'Stuart'),
(47, 'Asher', 'Pate', 'Caldwell'),
(48, 'Inga', 'Clements', 'Alvarez'),
(49, 'Lenore', 'Byers', 'Moody'),
(50, 'Wayne', 'Montoya', 'Short'),
(51, 'Ruth', 'Campos', 'Johnston'),
(52, 'Joelle', 'Lynn', 'Cross'),
(53, 'Patrick', 'Goff', 'Wilcox'),
(54, 'Neil', 'Winters', 'Frye'),
(55, 'Raya', 'Dalton', 'Bright'),
(56, 'Chester', 'Cobb', 'Peck'),
(57, 'Aquila', 'Perkins', 'Mcdowell'),
(58, 'Francis', 'Paul', 'Rodriquez'),
(59, 'Blair', 'Sampson', 'Kim'),
(60, 'Deirdre', 'Castaneda', 'Mathews'),
(61, 'Julian', 'Cervantes', 'Decker'),
(62, 'Hashim', 'Franks', 'Livingston'),
(63, 'Gareth', 'Odom', 'Bass'),
(64, 'Denise', 'Cain', 'Fisher'),
(65, 'Palmer', 'Waller', 'Rocha'),
(66, 'Kiona', 'Robbins', 'Pope'),
(67, 'Ivor', 'Farmer', 'Saunders'),
(68, 'Hermione', 'Case', 'Galloway'),
(69, 'Orla', 'Parks', 'Levine'),
(70, 'Christian', 'Compton', 'Phelps'),
(71, 'Joel', 'Hardy', 'Dunn'),
(72, 'Wing', 'Joyner', 'Russo'),
(73, 'Michael', 'Schroeder', 'Maynard'),
(74, 'George', 'Woodard', 'Fuller'),
(75, 'Tobias', 'Morrow', 'Berger');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `user` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `genero` varchar(12) NOT NULL,
  `tipo` int(3) NOT NULL,
  `estado` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bolsas_bolsero`
--
ALTER TABLE `bolsas_bolsero`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Bolsas_Bolsero_fk0` (`id_bolsero`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `bolsas_pelador`
--
ALTER TABLE `bolsas_pelador`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Bolsas_Pelador_fk0` (`id_pelador`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `bolseros`
--
ALTER TABLE `bolseros`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `embarque`
--
ALTER TABLE `embarque`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `extra`
--
ALTER TABLE `extra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Extra_fk0` (`id_pelador`),
  ADD KEY `Extra_fk1` (`id_bolsero`);

--
-- Indices de la tabla `fruta`
--
ALTER TABLE `fruta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Fruta_fk0` (`id_productores`),
  ADD KEY `Fruta_fk1` (`id_embarque`);

--
-- Indices de la tabla `peladores`
--
ALTER TABLE `peladores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `productores`
--
ALTER TABLE `productores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `bolsas_bolsero`
--
ALTER TABLE `bolsas_bolsero`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `bolsas_pelador`
--
ALTER TABLE `bolsas_pelador`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `bolseros`
--
ALTER TABLE `bolseros`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;
--
-- AUTO_INCREMENT de la tabla `embarque`
--
ALTER TABLE `embarque`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `extra`
--
ALTER TABLE `extra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `fruta`
--
ALTER TABLE `fruta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `peladores`
--
ALTER TABLE `peladores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;
--
-- AUTO_INCREMENT de la tabla `productores`
--
ALTER TABLE `productores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bolsas_bolsero`
--
ALTER TABLE `bolsas_bolsero`
  ADD CONSTRAINT `Bolsas_Bolsero_fk0` FOREIGN KEY (`id_bolsero`) REFERENCES `bolseros` (`id`),
  ADD CONSTRAINT `bolsas_bolsero_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`);

--
-- Filtros para la tabla `bolsas_pelador`
--
ALTER TABLE `bolsas_pelador`
  ADD CONSTRAINT `Bolsas_Pelador_fk0` FOREIGN KEY (`id_pelador`) REFERENCES `peladores` (`id`),
  ADD CONSTRAINT `bolsas_pelador_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`);

--
-- Filtros para la tabla `extra`
--
ALTER TABLE `extra`
  ADD CONSTRAINT `Extra_fk0` FOREIGN KEY (`id_pelador`) REFERENCES `peladores` (`id`),
  ADD CONSTRAINT `Extra_fk1` FOREIGN KEY (`id_bolsero`) REFERENCES `bolseros` (`id`);

--
-- Filtros para la tabla `fruta`
--
ALTER TABLE `fruta`
  ADD CONSTRAINT `Fruta_fk0` FOREIGN KEY (`id_productores`) REFERENCES `productores` (`id`),
  ADD CONSTRAINT `Fruta_fk1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
