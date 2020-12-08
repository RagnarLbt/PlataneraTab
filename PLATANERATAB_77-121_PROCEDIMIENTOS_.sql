-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-12-2020 a las 01:53:23
-- Versión del servidor: 10.4.13-MariaDB
-- Versión de PHP: 7.4.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `platanera`
--
CREATE DATABASE IF NOT EXISTS `platanera` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `platanera`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `actCuentas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actCuentas` (IN `opc` INT, IN `id_` VARCHAR(20), IN `id_cu` VARCHAR(20), IN `con` VARCHAR(50), IN `ingr` FLOAT, IN `egr` FLOAT, IN `tzC` FLOAT, IN `ingAnt` FLOAT, IN `egrAnt` FLOAT, IN `saldoAnt` FLOAT, IN `embarque` INT)  NO SQL
BEGIN
	# OPC 1 Actualizar Dolares
    # OPC 2 Actualizar Pesos
    # OPC 3 Actualizar Bolsas
	IF opc=1 THEN
    	#Calculamos las cantidades a cambiar
        SET @newIngreso=ingr-ingAnt;
        SET @newEgreso=egr-egrAnt;
    	#Actualizar Dolares
        UPDATE dolares SET dolares.concepto=con, dolares.ingreso=ingr, dolares.egreso=egr, dolares.taza_cambio=tzC, dolares.saldo=dolares.saldo+((@newIngreso)-(@newEgreso)) WHERE dolares.id=id_;
        
        UPDATE dolares SET dolares.saldo=dolares.saldo+((@newIngreso)-(@newEgreso)) WHERE dolares.id>id_;
        
        #Actualizar Cuenta Dolares
        UPDATE cuenta_dolares SET cuenta_dolares.total_ingreso=cuenta_dolares.total_ingreso+@newIngreso, cuenta_dolares.total_egreso=cuenta_dolares.total_egreso+@newEgreso, cuenta_dolares.total_saldo=cuenta_dolares.total_saldo+((@newIngreso)-(@newEgreso)) WHERE cuenta_dolares.id=id_cu;
        
        IF tzC>0 THEN 
			# Calcular el valor en pesos (tzC*cant)
            SET @newIngr=CAST( (egr*tzC) as DECIMAL(10,2) );
            
            # Buscar el registro en cuenta Pesos para actualizar
            SET @idPesos=(SELECT pesos.id FROM pesos WHERE pesos.idDolar=id_);
            
            IF @idPesos>0 THEN
                # Buscar el ingreso anterior del registro a actualizar
                SET @ingPesos=(SELECT pesos.ingreso FROM pesos WHERE pesos.idDolar=id_);

                SET @newCant=(@newIngr-@ingPesos);

                # Actualizar Registro Pesos y Cuenta Pesos 
                UPDATE `pesos` SET `ingreso`=`ingreso`+@newCant, `saldo`=saldo+@newCant WHERE pesos.id=@idPesos;

                UPDATE `pesos` SET `saldo`=saldo+@newCant WHERE pesos.id_cuenta=id_cu AND pesos.id>@idPesos;

                # Actualizar Cuenta_Pesos
                UPDATE cuenta_pesos SET cuenta_pesos.total_ingreso=cuenta_pesos.total_ingreso+@newCant, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo+@newCant WHERE cuenta_pesos.id=id_cu;
            
            ELSE
                -- Registramos en pesos y actualizamos cuenta pesos
                SET @cantNew=CAST( (egr*tzC) as DECIMAL(10,2) );

                -- Datos para el insert en pesos
                SET @idPesosNew=CONCAT(embarque, (SELECT COUNT(pesos.id) FROM pesos, cuenta_pesos WHERE cuenta_pesos.id=pesos.id_cuenta AND cuenta_pesos.id_emb=embarque)+1);                
                SET @regPSal=(SELECT cuenta_pesos.total_saldo FROM cuenta_pesos WHERE cuenta_pesos.id=id_cu);

                -- INSERTAR EN PESOS
                INSERT INTO `pesos`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `gastos_embarque`, `idDolar`) VALUES (@idPesosNew, id_cu, con, @cantNew, 0, @regPSal+@cantNew, 0, id_);
                
                # Actualizar Cuenta_Pesos
                UPDATE cuenta_pesos SET cuenta_pesos.total_ingreso=cuenta_pesos.total_ingreso+@cantNew, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo+@cantNew WHERE cuenta_pesos.id=id_cu;
                
            END IF;
            
        END IF;
    
    
    ELSEIF opc=2 THEN
    	# Cantidades a modificar
        SET @newIngreso=ingr-ingAnt;
        SET @newEgreso=egr-egrAnt;
		
        UPDATE pesos SET pesos.concepto=con, pesos.ingreso=ingr, pesos.egreso=egr, pesos.saldo=pesos.saldo+((@newIngreso)-(@newEgreso)) WHERE pesos.id=id_;
        
        UPDATE pesos SET pesos.saldo=pesos.saldo+((@newIngreso)-(@newEgreso)) WHERE pesos.id>id_ AND pesos.id_cuenta=id_cu;
        
        #Actualizar Cuenta Dolares
        UPDATE cuenta_pesos SET cuenta_pesos.total_ingreso=cuenta_pesos.total_ingreso+@newIngreso, cuenta_pesos.total_egreso=cuenta_pesos.total_egreso+@newEgreso, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo+((@newIngreso)-(@newEgreso)) WHERE cuenta_pesos.id=id_cu;
        
    ELSEIF opc=3 THEN
    	# Cantidades a modificar
        SET @newIngreso=ingr-ingAnt;
        SET @newEgreso=egr-egrAnt;
		
        UPDATE bolsas SET bolsas.concepto=con, bolsas.ingreso=ingr, bolsas.egreso=egr, bolsas.saldo=bolsas.saldo+((@newIngreso)-(@newEgreso)) WHERE bolsas.id=id_;
        
        UPDATE bolsas SET bolsas.saldo=bolsas.saldo+((@newIngreso)-(@newEgreso)) WHERE bolsas.id>id_ AND bolsas.id_cuenta=id_cu;
        
        #Actualizar Cuenta Dolares
        UPDATE cuenta_bolsas SET cuenta_bolsas.ingreso=cuenta_bolsas.ingreso+@newIngreso, cuenta_bolsas.egreso=cuenta_bolsas.egreso+@newEgreso, cuenta_bolsas.saldo=cuenta_bolsas.saldo+((@newIngreso)-(@newEgreso)) WHERE cuenta_bolsas.id=id_cu;
        
        # Actualizar los saldos del proximo embarque si la cuenta del actual esta cerrada
        CALL actSaldosAnteriores(3, embarque, id_cu, @newIngreso, @newEgreso);
    
    END IF;
END$$

DROP PROCEDURE IF EXISTS `actEmbarquesSiguientes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actEmbarquesSiguientes` (IN `emb` INT, IN `tipo` INT, IN `cant` FLOAT)  NO SQL
BEGIN
	# Obtener Id de gastos_embarque
    SET @idGasto=(SELECT gastos_embarque.id FROM gastos_embarque WHERE gastos_embarque.id_embarque=emb AND gastos_embarque.id_gasto=tipo);
    
    # Actualizar Registro de gastos_embarque
    UPDATE gastos_embarque SET gastos_embarque.cantidad=gastos_embarque.cantidad+cant WHERE gastos_embarque.id=@idGasto;
    
    #Actualizar Embarque total_gasto
    UPDATE embarque SET embarque.total_gastos=embarque.total_gastos+cant WHERE embarque.id=emb;
    
    # Pesos
    # Buscar Registro de los gastos del embarque en Pesos
    SET @idPesos=(SELECT pesos.id FROM `pesos`, cuenta_pesos WHERE pesos.concepto=CONCAT('GE',emb) AND cuenta_pesos.id_emb=emb AND cuenta_pesos.id=pesos.id_cuenta ORDER BY pesos.id DESC LIMIT 1);
    
    SET @idCP=(SELECT pesos.id_cuenta FROM `pesos`, cuenta_pesos WHERE pesos.concepto=CONCAT('GE',emb) AND cuenta_pesos.id_emb=emb AND cuenta_pesos.id=pesos.id_cuenta ORDER BY pesos.id DESC LIMIT 1);
    
    # Id del proximo embarque en cuentas_pesos
    SET @idPrxEmb=(SELECT pesos.id_cuenta FROM pesos, cuenta_pesos WHERE cuenta_pesos.id_emb=(emb+1) AND cuenta_pesos.id=pesos.id_cuenta);
    
    # Actualizar Pesos
    UPDATE pesos SET pesos.egreso=pesos.egreso+cant, pesos.saldo=pesos.saldo-cant;
    
    # Actualizar los registros siguientes del mismo embarque
    UPDATE pesos SET pesos.saldo=pesos.saldo-cant WHERE pesos.id>@idPesos AND pesos.id_cuenta=@idCP;
    
    # Actualizar los registros siguientes del proximo embarque
    UPDATE pesos SET pesos.saldo=pesos.saldo-cant WHERE pesos.id_cuenta=@idPrxEmb;
    
    # Actualización de las cuentas pesos
    UPDATE cuenta_pesos SET cuenta_pesos.total_egreso=cuenta_pesos.total_egreso+cant, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo-cant WHERE cuenta_pesos.id=@idCP;
    
    UPDATE cuenta_pesos SET cuenta_pesos.total_saldo=cuenta_pesos.total_saldo-cant WHERE cuenta_pesos.id=@idPrxEmb;
   	 
END$$

DROP PROCEDURE IF EXISTS `actPesosCuenta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actPesosCuenta` (IN `embarque` INT, IN `cantidad` FLOAT)  BEGIN
	SET @concepto=CAST(CONCAT('GASTOS E', embarque) AS BINARY);
    
    -- Buscar datos del ultimo registro
    SET @regPesos=(SELECT pesos.id FROM pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id WHERE cuenta_pesos.id_emb=embarque AND pesos.mostrar=1 AND pesos.concepto=CONCAT('GASTOS E', embarque));
    
    SET @idCuenta=(SELECT pesos.id_cuenta FROM pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id WHERE cuenta_pesos.id_emb=embarque AND pesos.mostrar=1 LIMIT 1);
    
    IF @regPesos>0 THEN
    
    	-- Actualizar la tabla pesos
        UPDATE pesos SET egreso=egreso+cantidad, saldo=saldo-cantidad WHERE pesos.id=@regPesos;
        
        UPDATE pesos SET pesos.saldo=pesos.saldo-cantidad WHERE pesos.id>@regPesos AND pesos.id_cuenta=@idCuenta;
    
    ELSE
    	-- Buscar los datos para insertar
        SET	@regPesosSal=(SELECT cuenta_pesos.total_saldo FROM cuenta_pesos WHERE cuenta_pesos.id_emb=embarque);
    	-- INSERTAR EL REGISTRO CON CONCEPTO GEX
        -- ID para pesos
        SET @idNuevo=CONCAT(embarque, (SELECT COUNT(pesos.id) FROM pesos, cuenta_pesos WHERE cuenta_pesos.id_emb=embarque AND pesos.id_cuenta=cuenta_pesos.id)+1);
        
        INSERT INTO `pesos`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `gastos_embarque`) VALUES (@idNuevo, @idCuenta, @concepto, 0, cantidad, @regPesosSal-cantidad, cantidad);

    END IF;
    
	-- Actualizar cuenta pesos
	UPDATE cuenta_pesos SET total_egreso=total_egreso+cantidad, total_saldo=total_saldo-cantidad WHERE id=@idCuenta;
    
    
    -- ACTUALIZAR LOS SALDOS DEL SIGUIENTE EMBARQUE SI LA CUENTA DEL ACTUAL ESTA CERRADA
    CALL actSaldosAnteriores(2, embarque, @idCuenta, 0, cantidad);
    
END$$

DROP PROCEDURE IF EXISTS `actSaldosAnteriores`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actSaldosAnteriores` (IN `opc` INT, IN `emb` INT, IN `idCuenta` INT, IN `ingr` FLOAT, IN `egre` FLOAT)  NO SQL
BEGIN
	# Opc 1 para actualizar en dolares
    # Opc 2 para actualizar en pesos
    # Opc 3 para actualizar en bolsas
    
    SET @idCuentaEmba=(SELECT cuentas FROM embarque WHERE id=emb);
    
    IF @idCuentaEmba=1 THEN
    
# ===========================================================================================
    	# Actualizar registros de Dolares
        IF opc=1 THEN
        	UPDATE dolares SET dolares.saldo=dolares.saldo+(ingr-egre) WHERE dolares.id_cuentaD>idCuenta AND dolares.mostrar=1;
            
            UPDATE cuenta_dolares SET cuenta_dolares.total_saldo=cuenta_dolares.total_saldo+(ingr-egre) WHERE cuenta_dolares.id_emb=(emb+1);
       
# ===========================================================================================
        # Actualizar registros de Pesos
        ELSEIF opc=2 THEN
        	# Id de la cuenta del siguiente embarque
        	SET @idEmb = (SELECT id FROM cuenta_pesos WHERE id_emb=(emb+1));
        	
            UPDATE pesos SET pesos.saldo=pesos.saldo+(ingr-egre) WHERE pesos.id_cuenta=@idEmb AND pesos.mostrar=1;
            
             UPDATE cuenta_pesos SET cuenta_pesos.total_saldo=cuenta_pesos.total_saldo+(ingr-egre) WHERE  cuenta_pesos.id=@idEmb;
             
# ===========================================================================================
        
        # Actualizar registros de Bolsas
        ELSEIF opc=3 THEN
    	
            UPDATE bolsas SET bolsas.saldo=bolsas.saldo+(ingr-egre) WHERE bolsas.id_cuenta>idCuenta AND bolsas.mostrar=1;

            UPDATE cuenta_bolsas SET cuenta_bolsas.saldo=cuenta_bolsas.saldo+(ingr-egre) WHERE cuenta_bolsas.idemb=(emb+1);

        END IF;
        
    END IF;

END$$

DROP PROCEDURE IF EXISTS `actualizarBolsero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarBolsero` (IN `Id_b` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_b` INT)  NO SQL
UPDATE `bolseros` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM, `Tipo`=Tipo_b WHERE id = Id_b$$

DROP PROCEDURE IF EXISTS `actualizarPelador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPelador` (IN `id_p` INT, IN `Nombre_p` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_p` INT)  NO SQL
UPDATE peladores SET nombre=Nombre_p, Ap_p= ApP, Ap_M= ApM, Tipo= Tipo_p where id=id_p$$

DROP PROCEDURE IF EXISTS `actualizarPro`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPro` (IN `Id_pro` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
UPDATE `productores` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM
WHERE id = Id_pro$$

DROP PROCEDURE IF EXISTS `addAbono`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addAbono` (IN `productor` INT, IN `embarque` INT, IN `tipo_abono` INT, IN `cant` FLOAT)  BEGIN
	# Registrar en una variable la cantidad segun el tipo de pago
	SET @cantFun=0; SET @cantFer=0; SET @cantPag=0;

	IF tipo_abono=1 THEN
    	SET @cantFun=cant;
  ELSEIF tipo_abono=2 THEN
    	SET @cantFer=cant;
  ELSEIF tipo_abono=3 THEN
    	SET @cantPag=cant;
  END IF;

    # Registramos el tipo de gasto en una variable
    SET @tg=0;
    IF @cantFun>0 THEN 
    	SET @tg=29;
    ELSEIF @cantPag>0 THEN 
    	SET @tg=24;
    ELSEIF @cantFer>0 THEN 
    	SET @tg=23;
    END IF;
    -- Buscar el id del prestamo
    SET @buscPrestamo=(SELECT p.id FROM prestamos p, fruta WHERE fruta.id_productores=productor AND fruta.id_embarque=embarque AND fruta.id=p.id_fruta);
    -- Si existe Actualizar el registro
    
    IF @buscPrestamo>0 THEN
    	UPDATE prestamos SET `abono_fungicida`=`abono_fungicida`+@cantFun, `abono_fertilizante`=`abono_fertilizante`+@cantFer, `abono_prestamo`=`abono_prestamo`+@cantPag, `saldo_fungicida`=`saldo_fungicida`-@cantFun, `saldo_fertilizante`=`saldo_fertilizante`-@cantFer, `saldo_prestamo`=`saldo_prestamo`-@cantPag WHERE id=@buscPrestamo;
        -- Actualizar gastos_embarque restandole al gasto de fruta y añadiendo el nuevo gasto de tipo AbonoX
        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-cant) WHERE `id_embarque`=embarque AND `id_gasto`=1;
        
        SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=@tg);
        IF @buscGastAbono>0 THEN
            UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+cant) WHERE `id`=@buscGastAbono;
        ELSE
            SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
            INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, @tg, cant);
        END IF;
        
    -- Si no exites Insertar en la tabla prestamo
    ELSE
    	SET @buscFruta=(SELECT id FROM fruta WHERE id_productores=productor AND id_embarque=embarque);
        IF @buscFruta>0 THEN
        	SET @regSaFun=(SELECT saldo_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regSaFer=(SELECT saldo_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regSaPre=(SELECT saldo_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regPFun=(SELECT no_pagos_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regPFer=(SELECT no_pagos_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regPPag=(SELECT no_pagos_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regAbFun=(SELECT abono_cantidad_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regAbFer=(SELECT abono_cantidad_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
            SET @regAbPag=(SELECT abono_cantidad_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);

            SET @idPrest = CONCAT(embarque, productor);

            INSERT INTO `prestamos`(id, `id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idPrest, @buscFruta, @regSaFun, @regSaFer, @regSaPre, @regPFun, @regPFer, @regPPag, @cantFun, @cantFer, @cantPag, (@regSaFun-@cantFun), (@regSaFer-@cantFer), (@regSaPre-@cantPag), @regAbFun, @regAbFer, @regAbPag);
            -- Actualizar gastos_embarque restandole al gasto de fruta y añadiendo el nuevo gasto de tipo AbonoX
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-cant) WHERE `id_embarque`=embarque AND `id_gasto`=1;
        	SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=@tg);
        	IF @buscGastAbono>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+cant) WHERE `id`=@buscGastAbono;
        	ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
            	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, @tg, cant);
        	END IF;
        END IF;
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `addBolsas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addBolsas` (IN `embarque` INT, IN `concep` VARCHAR(50), IN `egre` FLOAT)  BEGIN
	SET @saldoBolsas=(SELECT saldo FROM cuenta_bolsas WHERE idemb=embarque);
    SET @idCB=(SELECT id FROM cuenta_bolsas WHERE idemb=embarque);
    SET @idB=CONCAT(embarque, (SELECT COUNT(bolsas.id) FROM bolsas, cuenta_bolsas WHERE cuenta_bolsas.id=bolsas.id_cuenta AND cuenta_bolsas.idemb=embarque)+1);
    
    UPDATE `cuenta_bolsas` SET `egreso`=`egreso`+egre,`saldo`=(`saldo`-egre) WHERE id=@idCB;
    
    INSERT INTO `bolsas`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `activo`) VALUES (@idB, @idCB, concep, 0, egre, (@saldoBolsas-egre), 1);
    
    -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    CALL actSaldosAnteriores(3, embarque, @idCB, 0, egre);
    
END$$

DROP PROCEDURE IF EXISTS `addBolsero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addBolsero` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `bolseros`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) VALUES (Nom, ApP, ApM, Tip)$$

DROP PROCEDURE IF EXISTS `addDolares`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addDolares` (IN `concep` VARCHAR(100), IN `embarque` INT, IN `ingre` FLOAT, IN `egre` FLOAT, IN `tazaC` FLOAT)  BEGIN
	SET @regCD=(SELECT total_saldo FROM cuenta_dolares WHERE id_emb=embarque ORDER BY id DESC LIMIT 1);
    SET @idCD=(SELECT id FROM cuenta_dolares WHERE id_emb=embarque);
    
    UPDATE `cuenta_dolares` SET `total_ingreso`=`total_ingreso`+ingre, `total_egreso`=`total_egreso`+egre, `total_saldo`=`total_saldo`+(ingre-egre) WHERE id=@idCD;
    
    IF tazaC>0 THEN
    	-- Registramos en dolares
    	SET @idD=CONCAT(embarque, (SELECT COUNT(dolares.id) FROM dolares, cuenta_dolares WHERE cuenta_dolares.id_emb=embarque AND cuenta_dolares.id=dolares.id_cuentaD)+1);
    	
        INSERT INTO `dolares`(`id`, `id_cuentaD`, `concepto`, `ingreso`, `egreso`, `saldo`, `taza_cambio`, `activo`) VALUES (@idD, @idCD, concep, ingre, egre, (@regCD+ingre-egre), tazaC, 1);
        
        -- Registramos en pesos y actualizamos cuenta pesos
    	SET @idCP=(SELECT id FROM cuenta_pesos WHERE id_emb=embarque);
        SET @cantNew=ROUND((egre*tazaC),2);
        
        -- Actualizar CUENTA_PESOS
        UPDATE `cuenta_pesos` SET `total_ingreso`=total_ingreso+@cantNew, `total_saldo`=total_saldo+@cantNew WHERE id=@idCP;
        
        -- Datos para el insert en pesos
        SET @idPesosNew=CONCAT(embarque, (SELECT COUNT(pesos.id) FROM pesos, cuenta_pesos WHERE cuenta_pesos.id=pesos.id_cuenta AND cuenta_pesos.id_emb=embarque)+1);
        SET @regPSal=(SELECT pesos.saldo FROM `pesos`, cuenta_pesos WHERE pesos.id_cuenta=cuenta_pesos.id AND cuenta_pesos.id_emb=embarque AND pesos.mostrar=1 ORDER BY pesos.id DESC LIMIT 1);
        
        -- INSERTAR EN PESOS
        INSERT INTO `pesos`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `gastos_embarque`, `idDolar`) VALUES (@idPesosNew, @idCP, concep, @cantNew, 0, @regPSal+@cantNew, 0, @idD);
        
        -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    	CALL actSaldosAnteriores(1, embarque, @idCD, ingre, egre);
        
        -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    	-- CALL actSaldosAnteriores(2, embarque, @idCP, @cantNew, 0);
        
    ELSE
    	SET @idD=CONCAT(embarque, (SELECT COUNT(dolares.id) FROM dolares, cuenta_dolares WHERE cuenta_dolares.id_emb=embarque AND cuenta_dolares.id=dolares.id_cuentaD)+1);
    	
        INSERT INTO `dolares`(`id`, `id_cuentaD`, `concepto`, `ingreso`, `egreso`, `saldo`, `activo`) VALUES (@idD, @idCD, concep, ingre, egre, (@regCD+ingre-egre), 1);
        
        -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    	CALL actSaldosAnteriores(1, embarque, @idCD, ingre, egre);
        
    END IF;
END$$

DROP PROCEDURE IF EXISTS `addEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmbarque` (IN `id_e` INT, IN `fecha_i` DATE)  NO SQL
BEGIN

INSERT INTO `embarque`(`id`, `fecha_inicio`, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, `contenedor`, `no_sello`, `cuentas`, `matricula`, `temperatura`, `nombre_conductor`) VALUES (id_e, fecha_i, 0, '', 0, '', '', 0, '', 0, '');

set @saldos=(SELECT cuentas FROM embarque WHERE id=(id_e-1));
-- Generar ID para la tabla cuenta_peso
set @idNuevo=CONCAT(id_e,(SELECT COUNT(id) FROM `cuenta_pesos` WHERE id_emb=id_e)+1);
-- Generar ID en la tabla pesos
set @idPesos=CONCAT(id_e,(SELECT COUNT(pesos.id) FROM pesos, cuenta_pesos WHERE pesos.id_cuenta=cuenta_pesos.id AND cuenta_pesos.id_emb=id_e)+1);

    -- Comprobar si la cuenta del embarque anterior esta cerrada
    IF @saldos=0 THEN 

        -- Registarar ID para la tabla cuenta_pesos
        INSERT INTO cuenta_pesos (`id`, `id_emb`, `total_saldo`) VALUES (@idNuevo, id_e, 0);

        -- Registrar ID en la tabla pesos
        INSERT INTO `pesos`(`id`, `id_cuenta`, `concepto`, `saldo`) VALUES (@idPesos, @idNuevo,'SALDO ANTERIOR', 0);

    ELSE
        
        /* Cargar el nuevo registro con los saldos anteriores */
        set @saldosFinales=(SELECT total_saldo from cuenta_pesos WHERE id_emb=(id_e-1));
        
        -- Registarar ID para la tabla cuenta_pesos
        INSERT INTO cuenta_pesos (`id`, `id_emb`, `total_saldo`) VALUES (@idNuevo, id_e, @saldosFinales);
        
        -- Registrar ID en la tabla pesos
        INSERT INTO `pesos`(`id`, `id_cuenta`, `concepto`, `saldo`) VALUES (@idPesos, @idNuevo,'SALDO ANTERIOR', @saldosFinales);

    END IF;


END$$

DROP PROCEDURE IF EXISTS `addPelador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addPelador` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `peladores`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) 
VALUES (Nom, ApP, ApM, Tip)$$

DROP PROCEDURE IF EXISTS `addPesos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addPesos` (IN `concep` VARCHAR(100), IN `ingre` FLOAT, IN `egre` FLOAT, IN `embarque` INT)  BEGIN
	SET @idCPesos=(SELECT id from cuenta_pesos WHERE id_emb=embarque);
    
    -- INSERTAR EN PESOS
    SET @idNewP=CONCAT(embarque, (SELECT COUNT(pesos.id) FROM pesos, cuenta_pesos WHERE cuenta_pesos.id=pesos.id_cuenta AND cuenta_pesos.id_emb=embarque)+1);
    SET @saldoP=(SELECT total_saldo FROM cuenta_pesos WHERE id_emb=embarque);
    
    INSERT INTO pesos (id, id_cuenta, concepto, ingreso, egreso, saldo, gastos_embarque, activo) VALUES (@idNewP, @idCPesos, concep, ingre, egre, @saldoP+(ingre-egre), 0, 1);
    
    UPDATE cuenta_pesos SET `total_ingreso`=`total_ingreso`+ingre, `total_egreso`=`total_egreso`+egre, `total_saldo`=`total_saldo`+(ingre-egre) WHERE id=@idCPesos;
    
    -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    CALL actSaldosAnteriores(2, embarque, @idCPesos, ingre, egre);
    
END$$

DROP PROCEDURE IF EXISTS `addPrestamo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addPrestamo` (IN `tipo` INT(2), IN `productor` INT(11), IN `embarque` INT(11), IN `cantidad` FLOAT, IN `noPagos` INT(3))  BEGIN
    
    SET @cat_fun=0; SET @cat_fer=0; SET @cat_pag=0;
    SET @noPagfun=0; SET @noPagfer=0; SET @noPagpag=0;
    
    IF tipo=1 THEN
        SET @cat_fun=cantidad;
    ELSEIF tipo=2 THEN
        SET @cat_fer=cantidad;
    ELSE
        SET @cat_pag=cantidad;
    END IF;

    -- Asiganar Tipo de Gasto a registrar
    SET @tg=0;
    IF @cat_fun>0 THEN
        SET @tg=28;
    ELSEIF @cat_pag>0 THEN
        SET @tg=21;	
    ELSEIF @cat_fer>0 THEN
        SET @tg=20;
    END IF;

    # Buscar si existe un registro en la tabla fruta para el productor en el embarque
    SET @buscPrestamo=(SELECT id FROM fruta WHERE id_productores=productor AND id_embarque=embarque);

    IF @buscPrestamo>0 THEN
        
        # Buscar el registro en pretamos para obtener sus saldos y no de pagos
        SET @idPrestamo=(SELECT prestamos.id FROM prestamos, fruta WHERE fruta.id = prestamos.id_fruta AND fruta.id=@buscPrestamo);

        IF @idPrestamo>0 THEN
            SET @saldoFun=(SELECT saldo_fungicida FROM `prestamos` WHERE prestamos.id=@idPrestamo );
            SET @saldoFer=(SELECT saldo_fertilizante FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            SET @saldoPre=(SELECT saldo_prestamo FROM `prestamos` WHERE  prestamos.id=@idPrestamo);
            SET @pagosFun=(SELECT no_pagos_fungicida FROM `prestamos` WHERE  prestamos.id=@idPrestamo);
            SET @pagosFer=(SELECT no_pagos_fertilizante FROM `prestamos` WHERE  prestamos.id=@idPrestamo);
            SET @pagosPre=(SELECT no_pagos_prestamo FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            
            -- Obtener el numero de pagos segun el tipo de prestamo
            SET @noPagfun=@pagosFun;
            SET @noPagfer=@pagosFer;
            SET @noPagpag=@pagosPre;
            
            IF tipo=1 THEN
                SET @noPagfun=noPagos;
            ELSEIF tipo=2 THEN
                SET @noPagfer=noPagos;
            ELSE
                SET @noPagpag=noPagos;
            END IF;
        
            -- Colocar 1 pago si el Numero de pago es 0 ya para poder hacer la división
            SET @divnoPagfun=0;
            SET @divnoPagfer=0;
            SET @divnoPagpag=0;
            IF @noPagfun=0 THEN SET @divnoPagfun=1; ELSE SET @divnoPagfun=@noPagfun; END IF;
            IF @noPagfer=0 THEN SET @divnoPagfer=1; ELSE SET @divnoPagfer=@noPagfer; END IF;
            IF @noPagpag=0 THEN SET @divnoPagpag=1; ELSE SET @divnoPagpag=@noPagpag; END IF;
            
            -- Actualizar el registro de la tabla prestamos
            UPDATE prestamos SET `fungicida`=`fungicida`+@cat_fun, `fertilizante`=`fertilizante`+@cat_fer, `prestamo`=`prestamo`+@cat_pag, `no_pagos_fungicida`=@noPagfun, `no_pagos_fertilizante`=@noPagfer, `no_pagos_prestamo`=@noPagpag, `saldo_fungicida`=`saldo_fungicida`+@cat_fun, `saldo_fertilizante`=`saldo_fertilizante`+@cat_fer, `saldo_prestamo`=`saldo_prestamo`+@cat_pag, `abono_cantidad_fungicida`=(`fungicida`)/@divnoPagfun, `abono_cantidad_fertilizante`=(`fertilizante`)/@divnoPagfer, `abono_cantidad_prestamo`=(`prestamo`)/@divnoPagpag WHERE `id`=@idPrestamo;
        
        ELSE

            SET @ultimoPrest=(SELECT prestamos.id from prestamos, fruta where fruta.id_productores=productor and fruta.id=prestamos.id_fruta ORDER BY prestamos.id DESC LIMIT 1);

            IF @ultimoPrest>0 then
                SET @saldoFun=(SELECT saldo_fungicida FROM `prestamos` WHERE prestamos.id=@ultimoPrest );
                SET @saldoFer=(SELECT saldo_fertilizante FROM `prestamos` WHERE prestamos.id=@ultimoPrest);
                SET @saldoPre=(SELECT saldo_prestamo FROM `prestamos` WHERE  prestamos.id=@ultimoPrest);
                SET @pagosFun=(SELECT no_pagos_fungicida FROM `prestamos` WHERE  prestamos.id=@ultimoPrest);
                SET @pagosFer=(SELECT no_pagos_fertilizante FROM `prestamos` WHERE  prestamos.id=@ultimoPrest);
                SET @pagosPre=(SELECT no_pagos_prestamo FROM `prestamos` WHERE prestamos.id=@ultimoPrest);
        
                -- Obtener el numero de pagos segun el tipo de prestamo
                SET @noPagfun=@pagosFun;
                SET @noPagfer=@pagosFer;
                SET @noPagpag=@pagosPre;
                IF tipo=1 THEN
                    SET @noPagfun=noPagos;
                ELSEIF tipo=2 THEN
                    SET @noPagfer=noPagos;
                ELSE
                    SET @noPagpag=noPagos;
                END IF;

                -- Colocar 1 pago si el Numero de pago es 0 ya para poder hacer la división
                SET @divnoPagfun=0;
                SET @divnoPagfer=0;
                SET @divnoPagpag=0;
                IF @noPagfun=0 THEN SET @divnoPagfun=1; ELSE SET @divnoPagfun=@noPagfun; END IF;
                IF @noPagfer=0 THEN SET @divnoPagfer=1; ELSE SET @divnoPagfer=@noPagfer; END IF;
                IF @noPagpag=0 THEN SET @divnoPagpag=1; ELSE SET @divnoPagpag=@noPagpag; END IF;

                SET @idNuevo=CONCAT(embarque, productor);
            
                -- INSERTAR en la tabla Prestamos
                INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @buscPrestamo, @cat_fun+@saldoFun, @cat_fer+@saldoFer, @cat_pag+@saldoPre, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0,  @cat_fun+@saldoFun, @cat_fer+@saldoFer, @cat_pag+@saldoPre, (@cat_fun+@saldoFun/@divnoPagfun), (@cat_fer+@saldoFer/@divnoPagfer), (@cat_pag+@saldoPre/@divnoPagpag) );
        
            ELSE

                -- Obtener el numero de pagos segun el tipo de prestamo
                IF tipo=1 THEN
                    SET @noPagfun=noPagos;
                ELSEIF tipo=2 THEN
                    SET @noPagfer=noPagos;
                ELSE
                    SET @noPagpag=noPagos;
                END IF;
            
                SET @idNuevo=CONCAT(embarque, productor);
            
                -- INSERTAR en la tabla Prestamos
                INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @buscPrestamo, @cat_fun, @cat_fer, @cat_pag, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0, @cat_fun, @cat_fer, @cat_pag, (@cat_fun/noPagos), (@cat_fer/noPagos), (@cat_pag/noPagos) );
        
            END IF;

        END IF;
    
    ELSE

        -- Generar id para la tabla fruta
        SET @idFruta=CONCAT(embarque, (SELECT COUNT(id) FROM fruta WHERE id_embarque=embarque)+1);
        
        -- Insertar en la tabla fruta
        INSERT INTO `fruta`(`id`,`id_productores`, `peso_kg`, `pago`, `saldo_abono`, `id_embarque`) VALUES (@idFruta, productor, 0, 0, 0, embarque);
        
        -- Buscar el ultimo registro en pretamos para obtener sus saldos y no de pagos
        SET @idPrestamo=(SELECT prestamos.id FROM `prestamos`, fruta WHERE fruta.id_productores=productor ORDER BY prestamos.id DESC LIMIT 1);
        
        -- Si existe un registro...
        IF @idPrestamo>0 THEN
            SET @saldoFun=(SELECT saldo_fungicida FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            SET @saldoFer=(SELECT saldo_fertilizante FROM `prestamos`, fruta WHERE  prestamos.id=@idPrestamo);
            SET @saldoPre=(SELECT saldo_prestamo FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            SET @pagosFun=(SELECT no_pagos_fungicida FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            SET @pagosFer=(SELECT no_pagos_fertilizante FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            SET @pagosPre=(SELECT no_pagos_prestamo FROM `prestamos` WHERE prestamos.id=@idPrestamo);
            
            -- Obtener el numero de pagos segun el tipo de prestamo
            SET @noPagfun=@pagosFun;
            SET @noPagfer=@pagosFer;
            SET @noPagpag=@pagosPre;
            IF tipo=1 THEN
                SET @noPagfun=noPagos;
            ELSEIF tipo=2 THEN
                SET @noPagfer=noPagos;
            ELSE
                SET @noPagpag=noPagos;
            END IF;

            -- Colocar 1 pago si el Numero de pago es 0 ya para poder hacer la división
            IF @noPagfun=0 THEN SET @noPagfun=1; END IF;
            IF @noPagfer=0 THEN SET @noPagfer=1; END IF;
            IF @noPagpag=0 THEN SET @noPagpag=1; END IF;

            -- Generar el ID nuevo del Prestamo
            SET @idNuevo=CONCAT(embarque, productor);

            -- INSERTAR en la tabla Prestamos
            INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @idFruta, @cat_fun+@saldoFun, @cat_fer+@saldoFer, @cat_pag+@saldoPre, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0, @cat_fun+@saldoFun, @cat_fer+@saldoFer, @cat_pag+@saldoPre, (@cat_fun+@saldoFun/@noPagfun), (@cat_fer+@saldoFer/@noPagfer), (@cat_pag+@saldoPre/@noPagpag) );

        ELSE
            -- Obtener el numero de pagos segun el tipo de prestamo
            IF tipo=1 THEN
                SET @noPagfun=noPagos;
            ELSEIF tipo=2 THEN
                SET @noPagfer=noPagos;
            ELSE
                SET @noPagpag=noPagos;
            END IF;
            
            SET @idNuevo=CONCAT(embarque, productor);

            -- INSERTAR en la tabla Prestamos
            INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @idFruta, @cat_fun, @cat_fer, @cat_pag, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0, @cat_fun, @cat_fer, @cat_pag, (@cat_fun/noPagos), (@cat_fer/noPagos), (@cat_pag/noPagos) );

        END IF;
    
    END IF;
    -- Actualizar o registrar gastos
    /*
    CALL regGastoEmbarque(embarque, @tg,cantidad);
    */
END$$

DROP PROCEDURE IF EXISTS `addProductores`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addProductores` (IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
INSERT INTO `productores`(`nombre`, `Ap_p`, `Ap_m`)
VALUES (Nombre, ApP, ApM)$$

DROP PROCEDURE IF EXISTS `add_peso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_peso` (IN `id_e` INT, IN `egre` FLOAT, IN `con` VARCHAR(100))  NO SQL
    COMMENT 'Se utilizará al insertar un nuevo egreso (Comisión Banco)'
BEGIN
 set @saldo=(SELECT saldo from pesos INNER join cuenta_pesos ON pesos.id_cuenta=cuenta_pesos.id
where cuenta_pesos.id_emb=id_e ORDER BY pesos.saldo DESC LIMIT 1);

  set @cuenta=(select id_cuenta from pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id
where cuenta_pesos.id_emb=id_e ORDER BY pesos.id_cuenta desc LIMIT 1);

INSERT into pesos(id_cuenta, concepto, egreso, saldo) VALUES (@cuenta, con, egre, @saldo-egre);

END$$

DROP PROCEDURE IF EXISTS `agregarCuentaD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarCuentaD` (IN `id_e` INT(20), IN `concepto` VARCHAR(255), IN `ingreso` FLOAT, IN `egreso` FLOAT, IN `saldo` FLOAT)  NO SQL
begin 
	set @exist=(SELECT COUNT(cuenta_dolares.id_emb) from cuenta_dolares where id_emb=id_e );
    
    IF @exist=0 then INSERT into cuenta_dolares( id_emb ,total_ingreso, total_egreso,  total_saldo) values (id_e, ingreso, egreso, 5645) ;
    
   
    set @id=(SELECT id from cuenta_dolares where id_emb=id_e);
    INSERT into dolares(id_cuentaD, concepto, ingreso, egreso, saldo) values (@id, concepto, ingreso, egreso, saldo);
    end if;
    
end$$

DROP PROCEDURE IF EXISTS `agregar_gastos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_gastos` (IN `id_emb` INT(20), IN `pes` INT(11), IN `pag` INT(11), IN `id_g` INT(20))  NO SQL
BEGIN
 set @count= (SELECT COUNT(id) from gastos_embarque where id_embarque = id_emb and id_gasto=1);
    
    if( @count=0)
        then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 				`cantidad`) VALUES (id_emb, 1, (pes * pag));
     ELSE UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + (pes * pag)) 			WHERE `id`=id_g;

 end IF;
    
end$$

DROP PROCEDURE IF EXISTS `cerraCuenta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cerraCuenta` (IN `embarque` INT)  BEGIN
	SET @saldoDolar=(SELECT total_saldo from cuenta_dolares WHERE id_emb=embarque);
    SET @saldoPesos=(SELECT total_saldo from cuenta_pesos WHERE id_emb=embarque);
    SET @saldoBolsas=(SELECT saldo from cuenta_bolsas WHERE idemb=embarque);
    
    -- Dolares
    SET @idCD=CONCAT((embarque+1), (SELECT COUNT(id) FROM cuenta_dolares WHERE id_emb=(embarque+1))+1);
    SET @idD=CONCAT((embarque+1), (SELECT COUNT(dolares.id) FROM dolares, cuenta_dolares WHERE cuenta_dolares.id_emb=(embarque+1) AND cuenta_dolares.id=dolares.id_cuentaD)+1);
    INSERT INTO cuenta_dolares (`id`, id_emb, total_saldo) VALUES (@idCD, (embarque+1), @saldoDolar);
    INSERT INTO `dolares`(`id`, `id_cuentaD`, `concepto`, `saldo`) VALUES (@idD, @idCD,'SALDO ANTERIOR', @saldoDolar);
    
    -- Bolsas
    SET @idCB=CONCAT((embarque+1), (SELECT COUNT(id) FROM cuenta_bolsas WHERE idemb=(embarque+1))+1);
    SET @idB=CONCAT((embarque+1), (SELECT COUNT(bolsas.id) FROM bolsas, cuenta_bolsas WHERE cuenta_bolsas.idemb=(embarque+1) AND cuenta_bolsas.id=bolsas.id_cuenta)+1);
    
    INSERT INTO cuenta_bolsas (id, idemb, saldo) VALUES (@idCB, (embarque+1), @saldoBolsas);
    INSERT INTO `bolsas`(`id`, `id_cuenta`, `concepto`, `saldo`) VALUES (@idB, @idCB, 'SALDO ANTERIOR', @saldoBolsas);
    
    -- Pesos
    SET @idCP=(SELECT cuenta_pesos.id FROM `cuenta_pesos` WHERE cuenta_pesos.id_emb=(embarque+1));
    UPDATE `pesos` SET `saldo`=`saldo`+@saldoPesos WHERE id_cuenta=@idCP;
    UPDATE cuenta_pesos SET total_saldo=total_saldo+@saldoPesos WHERE id=@idCP;
    
    -- Actualizar Embarque
    UPDATE embarque SET cuentas=1 WHERE id=embarque;
END$$

DROP PROCEDURE IF EXISTS `delCuentas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delCuentas` (IN `opc` INT, IN `idBanco` VARCHAR(25), IN `idCuenta` VARCHAR(25), IN `ingr` FLOAT, IN `egr` FLOAT, IN `tz` FLOAT)  NO SQL
BEGIN
	# OPC 1 para ELIMINAR Dolares
	# OPC 2 para ELIMINAR Pesos
	# OPC 3 para ELIMINAR Bolsas

# ========================================================================================
    IF opc=1 THEN
    # Id del embarque
    SET @emb=(SELECT id_emb FROM cuenta_dolares WHERE id=idCuenta);
    
    	UPDATE dolares SET dolares.concepto='', dolares.ingreso=0, dolares.egreso=0, dolares.saldo=0, dolares.taza_cambio=0, dolares.activo=0, dolares.mostrar=0 WHERE dolares.id=idBanco;
        
        UPDATE dolares SET dolares.saldo=dolares.saldo+((-1*ingr)-(-1*egr)) WHERE dolares.id>idBanco AND dolares.id_cuentaD=idCuenta;
        
        IF tz>0 THEN
       		SET @catPesos=(tz*egr);
            SET @idPesos=(SELECT pesos.id FROM pesos WHERE pesos.idDolar=idBanco);
            SET @idCP=(SELECT pesos.id_cuenta FROM pesos WHERE pesos.idDolar=idBanco);
            
            UPDATE pesos SET pesos.concepto='', pesos.egreso=0, pesos.saldo=0, pesos.activo=0, pesos.mostrar=0 WHERE pesos.id=@idPesos;
            
            UPDATE pesos SET pesos.saldo=pesos.saldo-@catPesos WHERE pesos.id>@idPesos AND pesos.id_cuenta=@idCP;
            
            UPDATE cuenta_pesos SET cuenta_pesos.total_ingreso=cuenta_pesos.total_ingreso-@catPesos, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo-@catPesos WHERE cuenta_pesos.id=@idCP;
            
            # Actualizar los saldos de los proximos embarques si la cuenta del actual esta cerrada
       		CALL actSaldosAnteriores(2, @emb, idCuenta, (-1*@catPesos), 0);
            
        END IF;
        
        UPDATE cuenta_dolares set cuenta_dolares.total_ingreso=cuenta_dolares.total_ingreso-ingr, cuenta_dolares.total_egreso=cuenta_dolares.total_egreso-egr, cuenta_dolares.total_saldo=cuenta_dolares.total_saldo+((-1*ingr)-(-1*egr)) WHERE cuenta_dolares.id=idCuenta;
        
        # Actualizar los saldos de los proximos embarques si la cuenta del actual esta cerrada
       	CALL actSaldosAnteriores(1, @emb, idCuenta, (-1*ingr), (-1*egr) );
    
# ==================================================================================
    ELSEIF opc=2 THEN
    
    	SET @emb=(SELECT id_emb FROM cuenta_pesos WHERE id=idCuenta);
    
    	UPDATE pesos SET pesos.concepto='', pesos.ingreso=0, pesos.egreso=0, pesos.saldo=0, pesos.gastos_embarque=0, pesos.activo=0, pesos.mostrar=0 WHERE pesos.id=idBanco;
        
        UPDATE pesos SET pesos.saldo=pesos.saldo+((-1*ingr)-(-1*egr)) WHERE pesos.id>idBanco AND pesos.id_cuenta=idCuenta;
        
        UPDATE cuenta_pesos SET cuenta_pesos.total_ingreso=cuenta_pesos.total_ingreso-ingr, cuenta_pesos.total_egreso=cuenta_pesos.total_egreso-egr, cuenta_pesos.total_saldo=cuenta_pesos.total_saldo+((-1*ingr)-(-1*egr)) WHERE cuenta_pesos.id=idCuenta;
   		
        
        # Actualizar los saldos de los proximos embarques si la cuenta del actual esta cerrada
       	CALL actSaldosAnteriores(2, @emb, idCuenta, (-1*ingr), (-1*egr) );

# ==============================================================================================
    ELSEIF opc=3 THEN 
    	
        UPDATE bolsas SET bolsas.concepto='', bolsas.ingreso=0, bolsas.egreso=0, bolsas.saldo=0,
        bolsas.activo=0, bolsas.mostrar=0 WHERE bolsas.id=idBanco;
        
        UPDATE bolsas SET bolsas.saldo=bolsas.saldo+((-1*ingr)-(-1*egr)) WHERE bolsas.id>idBanco AND bolsas.id_cuenta=idCuenta;
        
        UPDATE cuenta_bolsas SET  cuenta_bolsas.ingreso=cuenta_bolsas.ingreso-ingr, cuenta_bolsas.egreso=cuenta_bolsas.egreso-egr, cuenta_bolsas.saldo=cuenta_bolsas.saldo+((-1*ingr)-(-1*egr)) WHERE cuenta_bolsas.id=idCuenta;
        
       # Actualizar los saldos de los proximos embarques si la cuenta del actual esta cerrada
       SET @emb=(SELECT idemb FROM cuenta_bolsas WHERE id=idCuenta);
       CALL actSaldosAnteriores(3, @emb, idCuenta, (-1*ingr), (-1*egr) );
        
    END IF;

END$$

DROP PROCEDURE IF EXISTS `deleteBolsero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteBolsero` (IN `id_b` INT)  NO SQL
DELETE from bolseros where id= id_b$$

DROP PROCEDURE IF EXISTS `deletePelador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePelador` (IN `Id_p` INT)  NO SQL
DELETE FROM `peladores` WHERE id = Id_p$$

DROP PROCEDURE IF EXISTS `deleteProd`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProd` (IN `Id_p` INT)  NO SQL
DELETE from productores WHERE id = Id_p$$

DROP PROCEDURE IF EXISTS `elimGastoEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `elimGastoEmbarque` (IN `idg` INT, IN `cant` FLOAT, IN `embarque` INT)  BEGIN
    
	-- DELETE FROM gastos_embarque WHERE id=idg;
    UPDATE gastos_embarque SET cantidad=0 WHERE id=idg; 
    
    UPDATE `embarque` SET `total_gastos`=`total_gastos`-cant WHERE id=embarque;
    
    CALL actPesosCuenta(embarque, (-1*cant) );
END$$

DROP PROCEDURE IF EXISTS `finalizarEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `finalizarEmbarque` (IN `idE` INT, IN `fecha` DATE, IN `sello` VARCHAR(25), IN `matricula` VARCHAR(25), IN `contenedor` VARCHAR(25), IN `temperatura` VARCHAR(5), IN `conductor` VARCHAR(30), IN `noBolsas` INT, IN `bolPerdidas` INT, IN `aguinaldo` FLOAT, IN `bolToston` INT(10))  NO SQL
BEGIN

	UPDATE `embarque` SET `fecha_fin`=fecha, `contenedor`=contenedor, `no_sello`=sello, `matricula`=matricula,`temperatura`=temperatura, `nombre_conductor`=conductor, perdida=bolPerdidas, bolsas_exitentes=noBolsas, bolsas_toston=bolToston WHERE `id`=idE;
    
    DELETE from bolsas_diarias where id_embarque=idE;

	-- Registramos el gasto y actualizar cuenta
    -- CALL regGastoEmbarque(idE, 27, aguinaldo, 0);
    
    -- Eliminar el registro de bolsas del embarque anterior
    DELETE FROM `bolsas_diarias` WHERE `id_embarque`=(idE);

END$$

DROP PROCEDURE IF EXISTS `modGastoEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `modGastoEmbarque` (IN `idG` INT, IN `embarque` INT, IN `cant` FLOAT, IN `cant_new` FLOAT)  BEGIN
	
    UPDATE gastos_embarque SET cantidad=cant_new WHERE id=idG;
    
    SET @cantiMod=cant_new-cant;
    
    UPDATE embarque SET total_gastos=total_gastos+@cantiMod WHERE id=embarque;
    
    CALL actPesosCuenta(embarque, @cantiMod);
END$$

DROP PROCEDURE IF EXISTS `modPesasCapturadas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `modPesasCapturadas` (IN `idFruta` VARCHAR(25), IN `idProFruta` VARCHAR(25), IN `pesoNew` FLOAT, IN `pagoNew` FLOAT, IN `embarque` INT, IN `cantidad` FLOAT)  NO SQL
BEGIN

	UPDATE productor_fruta SET productor_fruta.peso=productor_fruta.peso+pesoNew WHERE productor_fruta.id  =idProFruta;
    
    UPDATE fruta SET fruta.pago=pagoNew, fruta.peso_kg=fruta.peso_kg+pesoNew, fruta.saldo_abono=fruta.pago*fruta.peso_kg WHERE fruta.id=idFruta;
    
    -- Toneladas del embarque
    UPDATE embarque SET toneladas=toneladas+(0.001*pesoNew) WHERE id=embarque;
    
    CALL regGastoEmbarque(embarque, 1, cantidad, 0);

END$$

DROP PROCEDURE IF EXISTS `opt_gastos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `opt_gastos` (IN `op` INT(10), IN `tipo` INT(10), IN `id_g` INT(20), IN `id_emb` INT(20), IN `peso` INT(10), IN `pago` INT(10))  NO SQL
CASE op 
    when 1 then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 					`cantidad`) VALUES (id_emb, tipo, (peso * pago)) ;
    when 2 then UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + 					(peso * pago)) WHERE `id`=id_g;
    when 3 then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 					`cantidad`) VALUES (id_emb, tipo, pago); 
    when 4 then  UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + 					pago) WHERE `id`=id_g;
  
    
    end case$$

DROP PROCEDURE IF EXISTS `regBOLExtra`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regBOLExtra` (IN `opc` INT, IN `embarque` INT, IN `nom` VARCHAR(50), IN `ap` VARCHAR(50), IN `anios` INT, IN `tel` VARCHAR(14), IN `dir` VARCHAR(100), IN `cuen` VARCHAR(50), IN `trab` VARCHAR(50), IN `pag` FLOAT, IN `fec` DATE, IN `id_dat` INT)  BEGIN
	SET @emb=embarque;
	# Si opc es 1 entonces registramos al trabajador
    # Si opc es >3 (ya que enviamos el ID) entonces modificamos los datos del trabajador
    # Si opc es 3 entonces *"Eliminamos"* los datos del trabajador
	IF opc=1 THEN
    	SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM bolsero_extra WHERE id_embarque=embarque)+1);
    	INSERT INTO `bolsero_extra`(`id`, `nombre`, `apellidos`, `edad`, `telefono`, `direccion`, `cuenta`, `actividad`, `pago`, `id_embarque`, `fecha`) VALUES (@idNew, nom, ap, anios, tel, dir, cuen, trab, pag, embarque, fec);
        
        -- Actualizar Gastos (Tipo Bolsero ~3~) de embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
        UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
            INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
        END IF;
        CALL actPesosCuenta(embarque, pag);
    
    ELSEIF opc=2 THEN
    	# Buscamos el pago anterior para despues validar si cambio la cantidad
    	SET @pagoAnt=(SELECT pago FROM bolsero_extra WHERE id=id_dat);
        SET @cantidadNew=pag-@pagoAnt;
        #Actualizamos el registro
    	UPDATE `bolsero_extra` SET `nombre`=nom, `apellidos`=ap, `edad`=anios, `telefono`=tel, `direccion`=dir, `cuenta`=cuen, `actividad`=trab, `pago`=pag, `fecha`=fec WHERE id=id_dat;
    	
        IF pag != @pagoAnt THEN
        	-- Actualizar Gastos (Tipo Bolsero ~3~) de embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            
            UPDATE `embarque` SET total_gastos=total_gastos+@cantidadNew WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
                UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@cantidadNew) WHERE `id`=@buscGastPT;
            ELSE
                SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @cantidadNew);
            END IF;
            CALL actPesosCuenta(embarque, @cantidadNew);
        END IF;
    
    ELSEIF opc=3 THEN
    	UPDATE `bolsero_extra` SET `nombre`='', `apellidos`='', `edad`=0, `telefono`='', `direccion`='', `cuenta`='', `actividad`='', `pago`=0, `fecha`='' WHERE id=id_dat;
        
        -- Actualizar Gastos (Tipo Bolsero ~3~) de embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
        UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
            INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pg);
		END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
    END IF;
END$$

DROP PROCEDURE IF EXISTS `regBolsas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regBolsas` (IN `embarque` INT, IN `pelador` INT, IN `productor` INT, IN `bolsero` VARCHAR(10), IN `fecha` DATE, IN `hora` VARCHAR(30) CHARSET utf8mb4, IN `num_bol` INT(5), IN `pagoPel` FLOAT)  BEGIN
	SET @emb=embarque;
	-- Buscar datos del pelador
	SET @idBP=(SELECT id FROM bolsas_pelador WHERE id_embarque=embarque AND id_pelador=pelador AND fecha_trabajo_pe=fecha);
    IF @idBP>0 THEN
    	-- Si exixten actualizar
    	UPDATE `bolsas_pelador` SET `cantidad_bolsas_pe`= (`cantidad_bolsas_pe` + 1), pago_pe=pago_pe+(pagoPel) WHERE `id`=@idBP;
    ELSE
    	-- Si no Insertar
    	SET @idBPel=CONCAT(embarque, (SELECT COUNT(`id`) FROM `bolsas_pelador` WHERE `id_embarque`=embarque)+1);
    	INSERT INTO `bolsas_pelador`(`id`,`id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`) VALUES (@idBPel, pelador, embarque, fecha, 1, pagoPel);
    END IF;
    
    -- Actualizar la cantidad de bolsas del productor
    UPDATE `fruta` SET `cant_bolsas`=`cant_bolsas`+1 WHERE `id_embarque`=embarque AND `id_productores`=productor;
    
    -- Actualizar cantidad de bolsas del embarque y gastos totales
    UPDATE `embarque` SET `cant_bolsas_embarque`= (`cant_bolsas_embarque`+1), `total_gastos`=`total_gastos`+pagoPel WHERE id=@emb;
    
    -- INSERTAR en la tabla bolsas diarias la bolsas agregada
    SET @idBolDia=CONCAT(embarque, (SELECT COUNT(`id`) FROM `bolsas_diarias` WHERE `id_embarque`=embarque)+1);
    set @value=(SELECT SUM(bd.cantidad_bolsas_pe) from bolsas_pelador bd where bd.id_pelador=pelador and bd.id_embarque=embarque and bd.fecha_trabajo_pe=fecha );
    
    INSERT INTO `bolsas_diarias`(`id`,`numero`, `id_embarque`, `hora`, `fecha`, `pelador`, `id_bolsero`, `id_productor`, valor) VALUES (@idBolDia, (num_bol+1), embarque, hora, fecha, pelador, bolsero, productor, @value);
    
    # Actualizar gastos de embarque y cuenta pesos 
    SET @gastosEmb=(SELECT `id` FROM `gastos_embarque` WHERE `id_embarque`=embarque AND `id_gasto`=2);
    IF @gastosEmb>0 THEN
    	UPDATE `gastos_embarque` SET `cantidad`=`cantidad`+pagoPel WHERE `id`=@gastosEmb;
        CALL actPesosCuenta(embarque, pagoPel);
    ELSE
    	SET @idNewGasto=CONCAT(embarque, (SELECT COUNT(id) FROM `gastos_embarque` WHERE `id_embarque`=embarque)+1);
        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idNewGasto, embarque, 2, pagoPel);
        CALL actPesosCuenta(embarque, pagoPel);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `regFruta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regFruta` (IN `productor` INT(4), IN `embarque` INT(11), IN `peso` FLOAT, IN `fecha` DATE, IN `img` VARCHAR(255), IN `pago_f` FLOAT, IN `hora` VARCHAR(25))  BEGIN
	-- Buscar si existe registro de Fruta para el productor
	SET @buscarFruta=(SELECT id FROM fruta WHERE id_productores=productor AND id_embarque=embarque);
    
    IF @buscarFruta>0 THEN
        -- Actualizar al productor en la tabla fruta
        UPDATE `fruta` SET `peso_kg`=`peso_kg`+peso,`pago`=pago_f,`saldo_abono`=`peso_kg`*`pago` WHERE `id`=@buscarFruta;
        
        -- Generar Id para productor_fruta
        SET @idNewPF=CONCAT(embarque, (SELECT COUNT(productor_fruta.id) FROM productor_fruta, fruta WHERE productor_fruta.id_fruta=fruta.id AND fruta.id_embarque=embarque)+1);
        
        -- Registramos en la tabla productor_fruta
        INSERT INTO `productor_fruta`(`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`, hora_compra) VALUES (@idNewPF, @buscarFruta, peso, img, fecha, hora);
        
        -- Toneladas del embarque
        UPDATE embarque SET toneladas=toneladas+(0.001*peso) WHERE id=embarque;
        
        -- Registramos el gasto y actualizar cuenta
    	CALL regGastoEmbarque(embarque, 1, (peso*pago_f), 0);
        
    ELSE
        -- Generar Id para Fruta
        SET @idNuevo=CONCAT(embarque, (SELECT COUNT(id) FROM fruta WHERE id_embarque=embarque )+1);
        
        -- Registrar En la tabla Fruta
        INSERT INTO `fruta`(`id`, `id_productores`, `peso_kg`, `pago`, `saldo_abono`, `id_embarque`) VALUES (@idNuevo, productor, peso, pago_f, (pago_f*peso), embarque);
        
        -- Generar Id para productor_fruta
        SET @idNewPF=CONCAT(embarque, (SELECT COUNT(productor_fruta.id) FROM productor_fruta, fruta WHERE productor_fruta.id_fruta=fruta.id AND fruta.id_embarque=embarque)+1);
        
        -- Registramos en la tabla productor_fruta
        INSERT INTO `productor_fruta`(`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`, hora_compra) VALUES (@idNewPF, @idNuevo, peso, img, fecha, hora); 
        
        -- Toneladas del embarque
        UPDATE embarque SET toneladas=toneladas+(0.001*peso) WHERE id=embarque;
        
        -- Registramos el gasto y actualizar cuenta
    	CALL regGastoEmbarque(embarque, 1, (peso*pago_f), 0);
        
    END IF;
END$$

DROP PROCEDURE IF EXISTS `regGastoEmb`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regGastoEmb` (IN `embarque` INT, IN `tg` INT, IN `cant` FLOAT, IN `concepto` VARCHAR(50))  BEGIN
	SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`, `extra`) VALUES (@idNew, embarque, tg, cant, concepto);
    UPDATE embarque SET total_gastos=total_gastos+cant WHERE id=embarque;
    CALL actPesosCuenta(embarque, cant);
END$$

DROP PROCEDURE IF EXISTS `regGastoEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regGastoEmbarque` (IN `embarque` INT, IN `tipo` INT, IN `cant` FLOAT, IN `kg` FLOAT)  BEGIN
	set @emb=embarque;
	SET @buscGasto=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=tipo);
    
    IF @buscGasto>0 THEN
    	UPDATE gastos_embarque SET cantidad=cantidad+cant WHERE id=@buscGasto;
    ELSE
    	SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
    	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idNew, embarque, tipo, cant);
    END IF;
    
    IF kg>0 THEN
    	SET @idCB=(SELECT id FROM cuenta_bolsas WHERE idemb=embarque);
        SET @saldoCB=(SELECT saldo FROM cuenta_bolsas WHERE idemb=embarque);
    	SET @idB=CONCAT(embarque, (SELECT COUNT(bolsas.id) FROM bolsas, cuenta_bolsas WHERE cuenta_bolsas.id=bolsas.id_cuenta AND cuenta_bolsas.idemb=embarque)+1);
    	INSERT INTO `bolsas`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `activo`) VALUES (@idB, @idCB, 'COMPRA BOLSAS', kg, 0, @saldoCB+kg, 1);
        
        UPDATE cuenta_bolsas SET ingreso=ingreso+kg, saldo=saldo+kg WHERE id=@idCB;
        
        -- Actualizar los saldos del nuevo embarque si esque la cuenta del actual esta cerrada
        CALL actSaldosAnteriores(3, embarque, @idCB, kg, 0);
        
    END IF;
    
    UPDATE embarque SET total_gastos=total_gastos+cant WHERE id=@emb;
    
    CALL actPesosCuenta(embarque, cant);
END$$

DROP PROCEDURE IF EXISTS `regPeladorExtra`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regPeladorExtra` (IN `op` INT, IN `idP` INT, IN `idBP` VARCHAR(25), IN `trab` INT, IN `con` VARCHAR(50), IN `pag` FLOAT, IN `fech` DATE, IN `emb` INT, IN `id_extra` VARCHAR(25))  BEGIN
#op 1 = insertar trabajo extra para el pelador
#op 2 = update trabajo extra para el pelador
#op 3 = eliminar trabajo extra para el pelador
  	#===========INSERT===============
	IF op=1 THEN 
      #Generamos el id de la tabla pelador_extra
      set @idE= concat(emb, (SELECT COUNT(pelador_extra.id)FROM pelador_extra, bolsas_pelador where bolsas_pelador.id=pelador_extra.id_bolsaspelador and bolsas_pelador.id_embarque=emb)+1);
      
      #Buscamos si el pelador está en la lista de bolsas pelador
      SET @busPelador = (SELECT id FROM bolsas_pelador WHERE id_embarque=emb AND id_pelador=idP AND fecha_trabajo_pe=fech);

      #Si existe en la tabla bolsas pelador...
      IF @busPelador>0 THEN 
      
          #Insertamos en la tabla pelador_extra
         	INSERT INTO pelador_extra(id, id_bolsaspelador, trabajo, concepto, pago, fecha) VALUES(@idE, @busPelador, trab, con, pag, fech);
            
          #Modificamos el estado de tabla de bolsas pelador y sumamos el pago
          	UPDATE bolsas_pelador set bolsas_pelador.pago_pe = bolsas_pelador.pago_pe+pag, bolsas_pelador.estado = trab WHERE bolsas_pelador.id=@busPelador;
            
		#actualizamos el estado del pelador en la tabla donde están registrados todos
		UPDATE peladores set  peladores.estado=trab WHERE peladores.id=idP;

        -- Actualizar Gastos del embarque, cuenta pesos y embarque
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=emb AND id_gasto=2);

        UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=emb;
        IF @buscGastPT>0 THEN
        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
        ELSE
        SET @idGast=CONCAT(emb, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=emb)+1);
        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, emb, 2, pag);
        END IF;
        CALL actPesosCuenta(emb, pag);
                  
      #En caso de que el pelador no esté en la tabla de bosas pelador        
      ELSE
        # Creamos el nuevo id a insertar
        SET @idBolP=CONCAT(emb, (SELECT COUNT(id) FROM bolsas_pelador WHERE id_embarque=emb)+1);
        # Insertar en Bolsas_pelador
        INSERT INTO `bolsas_pelador`(`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`, `estado`) VALUES (@idBolP, idP, emb, fech, 0, pag, trab);

        #Insertamos en pelador extra
        INSERT into pelador_extra(id, id_bolsaspelador, trabajo,concepto, pago, fecha) values (@idE, @idBolP, trab, con, pag, fech);
#actualizamos el estado del pelador en la tabla donde están registrados todos
UPDATE peladores set  peladores.estado=trab WHERE peladores.id=idP;

        -- Actualizar Gastos del embarque, cuenta pesos y embarque
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=emb AND id_gasto=2);

        UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(emb, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=emb)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, emb, 2, pag);
        END IF;
        
        CALL actPesosCuenta(emb, pag);
      
    END IF;
 #===========UPDATE===============
    ELSEIF op=2 THEN 
      #Con el id de los peladores extra obtenenemos el dato anterior y hacemos la diferencia
    	SET @pagoEx=(SELECT pago FROM pelador_extra WHERE id=id_extra);
      	SET @pagoNew=pag-@pagoEx;
        
      #Actualizamos los datos de la tabla según el id de pelador extra
      UPDATE pelador_extra SET pelador_extra.trabajo=trab, pelador_extra.concepto=con, pelador_extra.pago=pag where pelador_extra.id=id_extra;
      
      #actualizamos el estado del pelador en la tabla donde están registrados todos
      set @idPelador=(SELECT bolsas_pelador.id_pelador FROM bolsas_pelador INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador where pelador_extra.id_bolsaspelador= id_extra);
UPDATE peladores set peladores.estado=trab WHERE peladores.id=@idPelador;

      #Actualizamos el estado del pelador en la tabla de bolsas pelador
      IF @pagoEx != pag THEN
        UPDATE bolsas_pelador SET bolsas_pelador.estado=trab, bolsas_pelador.pago_pe=bolsas_pelador.pago_pe+@pagonew WHERE bolsas_pelador.id=idBP;
        -- Actualizar Gastos del embarque, cuenta pesos y embarque
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=emb AND id_gasto=2);
        UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=emb;
        IF @buscGastPT>0 THEN
          UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
        ELSE
          SET @idGast=CONCAT(emb, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=emb)+1);
          INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, emb, 2, pag);
        END IF;
        CALL actPesosCuenta(emb, pag);

      ELSE
        UPDATE bolsas_pelador SET bolsas_pelador.estado=trab WHERE bolsas_pelador.id=idBP;
      END IF;

 #=============DELETE=============
    ELSEIF op=3 THEN
      
      UPDATE pelador_extra SET pelador_extra.pago=0, pelador_extra.fecha='', pelador_extra.concepto='', pelador_extra.trabajo=0 WHERE id=id_extra;
      
      UPDATE bolsas_pelador SET bolsas_pelador.pago_pe=bolsas_pelador.pago_pe-pag,  bolsas_pelador.estado=0 WHERE id=idBP;
      
      #actualizamos el estado del pelador en la tabla donde están registrados todos
      SET @idPelador=(SELECT bolsas_pelador.id_pelador FROM bolsas_pelador INNER JOIN pelador_extra on bolsas_pelador.id= pelador_extra.id_bolsaspelador where pelador_extra.id_bolsaspelador= id_extra);
UPDATE peladores set  peladores.estado=0 WHERE peladores.id=@idPelador;

      -- Actualizar Gastos del embarque, cuenta pesos y embarque
      SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=emb AND id_gasto=2);
      UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=emb;
      IF @buscGastPT>0 THEN
        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
      ELSE
        SET @idGast=CONCAT(emb, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=emb)+1);
        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, emb, 2, ((-1)*(pag)) );
      END IF;
      CALL actPesosCuenta(emb, (pag*-1) ); 

#===========FINALIZAR TRABAJO============
    ELSEIF op=4 THEN
    
    # Actualizar el estado del Pelador
    UPDATE bolsas_pelador SET bolsas_pelador.estado=0 WHERE id=idBP;
    
	END IF;
    
END$$

DROP PROCEDURE IF EXISTS `regTrabajoBo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoBo` (IN `embarque` INT, IN `bolId` INT, IN `fechaT` DATE, IN `pag` FLOAT)  BEGIN
	SET @emb=embarque;
	# Buscar si extste un registro para el bolsero en este embarque
    SET @idBBol=(SELECT id FROM bolsas_bolsero WHERE id_embarque=embarque AND id_bolsero=bolId);
    
    # Calculamos la diferencia de dias
    SET @difFech=(SELECT TIMESTAMPDIFF(DAY, fecha_inicio, fechaT) FROM embarque WHERE id=embarque);
    
    # Si se encontro actualizar segun la fecha
    IF @idBBol>0 THEN
    
    	IF @difFech=0 THEN
        	-- Dia 1
        	SET @pagExis=(SELECT cast(diaUno as INT) FROM bolsas_bolsero WHERE id=@idBBol);
            IF @pagExis=0 THEN
            	UPDATE bolsas_bolsero SET diaUno=diaUno+pag, pago_bol=pago_bol+pag WHERE id=@idBBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
            END IF;
            
        ELSEIF @difFech=1 THEN
        	-- Dia 2
            SET @pagExis=(SELECT cast(diaDos as INT) FROM bolsas_bolsero WHERE id=@idBBol);
            IF @pagExis=0 THEN
            	UPDATE bolsas_bolsero SET diaDos=diaDos+pag, pago_bol=pago_bol+pag WHERE id=@idBBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
            END IF;
            
        ELSEIF @difFech=2 THEN
        	-- Dia 3
            SET @pagExis=(SELECT cast(diaTres as INT) FROM bolsas_bolsero WHERE id=@idBBol);
            IF @pagExis=0 THEN
            	UPDATE bolsas_bolsero SET diaTres=diaTres+pag, pago_bol=pago_bol+pag WHERE id=@idBBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
            END IF;
            
        ELSEIF @difFech=3 THEN
        	-- Dia 4
            SET @pagExis=(SELECT cast(diaCuatro as INT) FROM bolsas_bolsero WHERE id=@idBBol);
            IF @pagExis=0 THEN
            	UPDATE bolsas_bolsero SET diaCuatro=diaCuatro+pag, pago_bol=pago_bol+pag WHERE id=@idBBol;
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            END IF;
            
        ELSEIF @difFech=4 THEN
        	-- Dia 5
            SET @pagExis=(SELECT cast(diaCinco as INT) FROM bolsas_bolsero WHERE id=@idBBol);
            IF @pagExis=0 THEN
            	UPDATE bolsas_bolsero SET diaCinco=diaCinco+pag, pago_bol=pago_bol+pag WHERE id=@idBBol;
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
            END IF;
            
        END IF;
        
    # Si no se encontro registro insertamos segun la fecha    
    ELSE
    	# Crearmos el nuevo id a insertar
    	SET @idBB=CONCAT(embarque, (SELECT COUNT(id) FROM bolsas_bolsero WHERE id_embarque=embarque)+1);
        IF @difFech=0 THEN
        -- Dia 1
    		INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaUno`, `pago_bol`) VALUES (@idBB, bolId, embarque, fechaT, pag, pag);
           	-- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
			ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
            END IF;
            CALL actPesosCuenta(embarque, pag); 
            
            
        ELSEIF @difFech=1 THEN
        -- Dia 2
        	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaDos`, `pago_bol`) VALUES (@idBB, bolId, embarque, fechaT, pag, pag);
           	-- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
			ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
            END IF;
            CALL actPesosCuenta(embarque, pag); 
            
            
        ELSEIF @difFech=2 THEN
        -- Dia 3
        	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaTres`, `pago_bol`) VALUES (@idBB, bolId, embarque, fechaT, pag, pag);
           	-- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
			ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
            END IF;
            CALL actPesosCuenta(embarque, pag); 
        
        
        ELSEIF @difFech=3 THEN
        -- Dia 4
        	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaCuatro`, `pago_bol`) VALUES (@idBB, bolId, embarque, fechaT, pag, pag);
           	-- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
			ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
            END IF;
            CALL actPesosCuenta(embarque, pag); 
            
            
        ELSEIF @difFech=4 THEN
        -- Dia 5
        	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaCinco`, `pago_bol`) VALUES (@idBB, bolId, embarque, fechaT, pag, pag);
           	-- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
			ELSE
            	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
            END IF;
            CALL actPesosCuenta(embarque, pag); 
            
        END IF;
        
    END IF;
END$$

DROP PROCEDURE IF EXISTS `regTrabajoExtra`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoExtra` (IN `opc` INT, IN `embarque` INT, IN `idBol` INT, IN `act` VARCHAR(100), IN `pag` FLOAT, IN `fech` DATE, IN `id_extra` INT, IN `id_bb` INT)  BEGIN
	# Opc 1 es registro
    # Opc 2 es modificar
    # Opc 3 es eliminar 
	
    SET @emb=embarque;
    # Diferencia de dias
    SET @difFech=(SELECT TIMESTAMPDIFF(DAY, fecha_inicio, fech) FROM embarque WHERE id=embarque);
    
# ============================================================
IF opc=1 THEN

	# Buscar registro de la tabal bolsas_bolsero
	SET @buscBol=(SELECT id FROM bolsas_bolsero WHERE id_embarque=embarque AND id_bolsero=idbol);
    # Generar Id
    SET @idE=CONCAT(embarque, (SELECT COUNT(extra.id) FROM extra, bolsas_bolsero WHERE bolsas_bolsero.id=extra.id_bolsas_bolsero AND bolsas_bolsero.id_embarque=embarque)+1);
    
    # Si existe el registro del bolsero
    IF @buscBol>0 THEN
    	# Comprobar si no existe un registro de trabajo extra activo para el bolsero
    	SET @regExtra=(SELECT COUNT(id) FROM extra WHERE id_bolsas_bolsero=@buscBol AND fecha=fech AND estado=1);
        
        IF @regExtra=0 THEN
            
            IF @difFech=0 THEN
            	# Insertar Trabajo Extra
                INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @buscBol, fech, act, pag, 1);
            	UPDATE bolsas_bolsero SET diaUno=diaUno+pag, pago_bol=pago_bol+pag WHERE id=@buscBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            ELSEIF @difFech=1 THEN
            	# Insertar Trabajo Extra
        		INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @buscBol, fech, act, pag, 1);
            	UPDATE bolsas_bolsero SET diaDos=diaDos+pag, pago_bol=pago_bol+pag WHERE id=@buscBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            ELSEIF @difFech=2 THEN
            	# Insertar Trabajo Extra
        		INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @buscBol, fech, act, pag, 1);
            	UPDATE bolsas_bolsero SET diaTres=diaTres+pag, pago_bol=pago_bol+pag WHERE id=@buscBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            ELSEIF @difFech=3 THEN
            	# Insertar Trabajo Extra
        		INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @buscBol, fech, act, pag, 1);
            	UPDATE bolsas_bolsero SET diaCuatro=diaCuatro+pag, pago_bol=pago_bol+pag WHERE id=@buscBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            ELSEIF @difFech=4 THEN
            	# Insertar Trabajo Extra
        		INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @buscBol, fech, act, pag, 1);
            	UPDATE bolsas_bolsero SET diaCinco=diaCinco+pag, pago_bol=pago_bol+pag WHERE id=@buscBol;
                
                -- Actualizar Gastos del embarque, cuenta pesos y embarque
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
                
            END IF;
            
         END IF;
         
    # Si no existe el registro del bolsero
    ELSE
    	# Creamos el nuevo id a insertar
    	SET @idBB=CONCAT(embarque, (SELECT COUNT(id) FROM bolsas_bolsero WHERE id_embarque=embarque)+1);
        
		IF @difFech=0 THEN
            -- Dia 1
            	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaUno`, `pago_bol`) VALUES (@idBB, idBol, embarque, fech, pag, pag);
                
            	INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @idBB, fech, act, pag, 1);

                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
             
		ELSEIF @difFech=1 THEN
             -- Dia 2
                INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaDos`, `pago_bol`) VALUES (@idBB, idBol, embarque, fech, pag, pag);
                
                INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @idBB, fech, act, pag, 1);
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
		ELSEIF @difFech=2 THEN
             -- Dia 3
                INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaTres`, `pago_bol`) VALUES (@idBB, idBol, embarque, fech, pag, pag);
                
                INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @idBB, fech, act, pag, 1);
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
		ELSEIF @difFech=3 THEN
             -- Dia 4
             	INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaCuatro`, `pago_bol`) VALUES (@idBB, idBol, embarque, fech, pag, pag);
                
                INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @idBB, fech, act, pag, 1);
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
		ELSEIF @difFech=4 THEN
             -- Dia 5
                INSERT INTO `bolsas_bolsero`(`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaCinco`, `pago_bol`) VALUES (@idBB, idBol, embarque, fech, pag, pag);
                
                INSERT INTO `extra`(`id`, `id_bolsas_bolsero`, `fecha`, `descripcion`, `pago`, `estado`) VALUES (@idE, @idBB, fech, act, pag, 1);
                
                -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag); 
                
       	END IF;
             
	END IF;
    
# ============================================================
ELSEIF opc=2 THEN
    	SET @pagoEx=(SELECT pago FROM extra WHERE id=id_extra);
        SET @pagoNew=pag-@pagoEx;
    
    IF @difFech=0 THEN
        UPDATE `extra` SET `pago`=pag, `descripcion`=act WHERE id=id_extra;
        IF @pagoEx != pag THEN
        	UPDATE bolsas_bolsero SET diaUno=diaUno+@pagoNew, pago_bol=pago_bol+@pagoNew WHERE id=id_bb;
            
            -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@pagoNew) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @pagoNew);
                END IF;
                CALL actPesosCuenta(embarque, @pagoNew);
                
        END IF;
        
    ELSEIF @difFech=1 THEN
    	UPDATE `extra` SET `pago`=pag, `descripcion`=act WHERE id=id_extra;
        IF @pagoEx != pag THEN
        	UPDATE bolsas_bolsero SET diaDos=diaDos+@pagoNew, pago_bol=pago_bol+@pagoNew WHERE id=id_bb;
            
            -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@pagoNew) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @pagoNew);
                END IF;
                CALL actPesosCuenta(embarque, @pagoNew);
                
        END IF;
        
    ELSEIF @difFech=2 THEN
    	UPDATE `extra` SET `pago`=pag, `descripcion`=act WHERE id=id_extra;
        IF @pagoEx != pag THEN
        	UPDATE bolsas_bolsero SET diaTres=diaTres+@pagoNew, pago_bol=pago_bol+@pagoNew WHERE id=id_bb;
            
            -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@pagoNew) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @pagoNew);
                END IF;
                CALL actPesosCuenta(embarque, @pagoNew);
                
        END IF;
        
    ELSEIF @difFech=3 THEN
    	UPDATE `extra` SET `pago`=pag, `descripcion`=act WHERE id=id_extra;
        IF @pagoEx != pag THEN
        	UPDATE bolsas_bolsero SET diaCuatro=diaCuatro+@pagoNew, pago_bol=pago_bol+@pagoNew WHERE id=id_bb;
            
            -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@pagoNew) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @pagoNew);
                END IF;
                CALL actPesosCuenta(embarque, @pagoNew);
                
        END IF;
    ELSEIF @difFech=4 THEN
    	UPDATE `extra` SET `pago`=pag, `descripcion`=act WHERE id=id_extra;
        IF @pagoEx != pag THEN
        	UPDATE bolsas_bolsero SET diaCinco=diaCinco+@pagoNew, pago_bol=pago_bol+@pagoNew WHERE id=id_bb;
            
            -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@pagoNew) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @pagoNew);
                END IF;
                CALL actPesosCuenta(embarque, @pagoNew);
                
        END IF;
        
	END IF;

# ============================================================
ELSEIF opc=3 THEN

	IF @difFech=0 THEN
    	UPDATE `extra` SET `pago`=0, fecha='', `descripcion`='', estado=0 WHERE id=id_extra;
        UPDATE bolsas_bolsero SET diaUno=diaUno-pag, pago_bol=pago_bol-pag WHERE id=id_bb;
        
        -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3,-pag);
        END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
                
    ELSEIF @difFech=1 THEN
    	UPDATE `extra` SET `pago`=0, fecha='', `descripcion`='', estado=0 WHERE id=id_extra;
        UPDATE bolsas_bolsero SET diaDos=diaDos-pag, pago_bol=pago_bol-pag WHERE id=id_bb;
        -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3,-pag);
        END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
    ELSEIF @difFech=2 THEN
    	UPDATE `extra` SET `pago`=0, fecha='', `descripcion`='', estado=0 WHERE id=id_extra;
        UPDATE bolsas_bolsero SET diaTres=diaTres-pag, pago_bol=pago_bol-pag WHERE id=id_bb;
        -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3,-pag);
        END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
    ELSEIF @difFech=3 THEN
    	UPDATE `extra` SET `pago`=0, fecha='', `descripcion`='', estado=0 WHERE id=id_extra;
        UPDATE bolsas_bolsero SET diaCuatro=diaCuatro-pag, pago_bol=pago_bol-pag WHERE id=id_bb;
        -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3,-pag);
        END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
    ELSEIF @difFech=4 THEN
    	UPDATE `extra` SET `pago`=0, fecha='', `descripcion`='', estado=0 WHERE id=id_extra;
        UPDATE bolsas_bolsero SET diaCinco=diaCinco-pag, pago_bol=pago_bol-pag WHERE id=id_bb;
        -- Actualizar gastos del embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=@emb;
        
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        	INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3,-pag);
        END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
	END IF;
    
END IF;
END$$

DROP PROCEDURE IF EXISTS `regTrabajoPT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoPT` (IN `embarque` INT, IN `fechaT` DATE, IN `pag` FLOAT, IN `planId` INT)  BEGIN
	SET @emb=embarque;
	SET @fechaEmb=(SELECT TIMESTAMPDIFF(DAY, fecha_inicio, fechaT) FROM embarque WHERE id=embarque);
    IF @fechaEmb>=0 AND @fechaEmb<=4 THEN
    	-- Buscar Registro en Bolsas_toston
    	SET @busPlanilla=(SELECT id FROM bolsas_toston WHERE id_embarque=embarque AND id_planilla=planId);
        -- Generar el nuevo Id
        SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM bolsas_toston WHERE id_embarque=embarque)+1);
        
    	IF @fechaEmb=0 THEN
        -- Dia 1
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaUno FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaUno=diaUno+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
                    -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
                END IF;
            ELSE
            	INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaUno`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
                -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                
                IF @buscGastPT>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                END IF;
                CALL actPesosCuenta(embarque, pag);
            END IF;
            
        ELSEIF @fechaEmb=1 THEN
        -- Dia 2
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaDos FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaDos=diaDos+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
                    -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
                END IF;
            ELSE
            	INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaDos`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
                -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
            END IF;
            
        ELSEIF @fechaEmb=2 THEN
        -- DIA 3
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaTres FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaTres=diaTres+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
                    -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
                END IF;
            ELSE
                INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaTres`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
                -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
           	END IF;
        
        ELSEIF @fechaEmb=3 THEN
        -- Dia 4        	
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaCuatro FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaCuatro=diaCuatro+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
                    -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
                END IF;
            ELSE
                INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaCuatro`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
                -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
           	END IF;
        
        ELSEIF @fechaEmb=4 THEN
        -- Dia 5
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaCinco FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaCinco=diaCinco+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
                    -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
                END IF;
            ELSE
                INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaCinco`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
                -- Actualizar gastos en embarque y gastos_embarque el nuevo gasto
                    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=@emb;
                    
                    IF @buscGastPT>0 THEN
                        UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+pag) WHERE `id`=@buscGastPT;
                    ELSE
                        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, pag);
                    END IF;
                    CALL actPesosCuenta(embarque, pag);
           	END IF;
        
        END IF;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `rendimiento`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `rendimiento` (IN `id_e` INT(11))  NO SQL
BEGIN
SET @peso=(select sum(fruta.peso_kg) from fruta where fruta.id_embarque=id_e);
            set @t= @peso*0.001;
            set @bolsas=(SELECT embarque.cant_bolsas_embarque from embarque where embarque.id =id_e);            
            SELECT embarque.fecha_inicio, embarque.fecha_fin, embarque.cant_bolsas_embarque as cant , @t as peso, @bolsas/@t as rendimiento FROM embarque INNER JOIN gastos_embarque on embarque.id=gastos_embarque.id_embarque where embarque.id=id_e LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `sumeerMultiplesBolsas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sumeerMultiplesBolsas` (IN `emb` INT(11), IN `idPel` INT(11), IN `idProd` INT(11), IN `fechaDia` DATE, IN `nume` INT(11), IN `pagoPel` INT(11), IN `bolsasNum` INT(11))  NO SQL
BEGIN
	
    SET @idPelDia=(SELECT id FROM bolsas_pelador WHERE id_embarque=emb AND id_pelador=idPel AND fecha_trabajo_pe=fechaDia);
    
    SET @prodReg=(SELECT id FROM fruta WHERE id_productores=idProd AND id_embarque=emb);
    
    -- Cantidad a insertar
    SET @cantidad=pagoPel*bolsasNum;
    
    IF @idPelDia>0 AND @prodReg>0 THEN
    	
        SET @estado=(SELECT estado FROM bolsas_pelador WHERE id=@idPelDia);
        
        IF @estado=0 THEN

            -- Actualizar numero de bolas y pago del pelador
            UPDATE bolsas_pelador SET cantidad_bolsas_pe=(cantidad_bolsas_pe + bolsasNum), pago_pe=pago_pe+(pagoPel*bolsasNum) WHERE id=@idPelDia;
            
            -- Actualizar la cantidad de bolsas del productor
        	UPDATE `fruta` SET `cant_bolsas`=`cant_bolsas`+bolsasNum WHERE id=@prodReg;
            
            -- Actualizar cantidad de bolsas del embarque
            UPDATE embarque SET cant_bolsas_embarque= (cant_bolsas_embarque + bolsasNum) WHERE id=emb;
            
            UPDATE embarque SET total_gastos=(total_gastos + @cantidad) WHERE id=emb;
            
            -- INSERTAR en la tabla bolsas diarias las bolsas agregada
        	-- SET @idBolDia=CONCAT(emb, (SELECT COUNT(`id`) FROM `bolsas_diarias` WHERE `id_embarque`=emb)+1);

        	-- INSERT INTO `bolsas_diarias`(`id`,`numero`, `id_embarque`, `hora`, `fecha`, `pelador`, `id_bolsero`, `id_productor`) VALUES (@idBolDia, (num_bol+1), emb, hora, fecha, pelador, bolsero, productor);

            # Actualizar gastos de embarque y cuenta pesos 
            SET @gastosEmb=(SELECT `id` FROM `gastos_embarque` WHERE `id_embarque`=emb AND `id_gasto`=2);
            
            IF @gastosEmb>0 THEN
                UPDATE `gastos_embarque` SET `cantidad`=`cantidad`+(pagoPel*bolsasNum) WHERE `id`=@gastosEmb;

                CALL actPesosCuenta(emb, (pagoPel*bolsasNum));
            
            ELSE
                
                SET @idNewGasto=CONCAT(emb, (SELECT COUNT(id) FROM `gastos_embarque` WHERE `id_embarque`=emb)+1);
                
                INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idNewGasto, emb, 2, (pagoPel*bolsasNum));

            	CALL actPesosCuenta(emb, (pagoPel*bolsasNum));
            
            END IF; -- Fin actualizar cunetas y gastos
        
        END IF; -- Fin de estado IF
        
    
     ELSEIF @prodReg>0 THEN -- Si no esta registrado el pelador en bolsas_pelador
    
    	# Crear id para registrar al pelador
        SET @idNew=CONCAT(emb, (SELECT COUNT(id) FROM bolsas_pelador WHERE id_embarque=emb)+1);
    	
        INSERT INTO bolsas_pelador(id, id_pelador, id_embarque, fecha_trabajo_pe, cantidad_bolsas_pe, pago_pe, estado) VALUES (@idNew, idPel, emb, fechaDia, bolsasNum, (pagoPel*bolsasNum), 0);
        
        -- Actualizar la cantidad de bolsas del productor
        UPDATE `fruta` SET `cant_bolsas`=`cant_bolsas`+bolsasNum WHERE id=@prodReg;
            
        -- Actualizar cantidad de bolsas del embarque
        UPDATE embarque SET cant_bolsas_embarque= (cant_bolsas_embarque + bolsasNum) WHERE id=emb;
        
        UPDATE embarque SET total_gastos=(total_gastos + @cantidad) WHERE id=emb;
         
        # Actualizar gastos de embarque y cuenta pesos 
        SET @gastosEmb=(SELECT `id` FROM `gastos_embarque` WHERE `id_embarque`=emb AND `id_gasto`=2);
         
         IF @gastosEmb>0 THEN
         	UPDATE `gastos_embarque` SET `cantidad`=`cantidad`+(pagoPel*bolsasNum) WHERE `id`=@gastosEmb;
            CALL actPesosCuenta(emb, (pagoPel*bolsasNum)); 
         ELSE
         	SET @idNewGasto=CONCAT(emb, (SELECT COUNT(id) FROM `gastos_embarque` WHERE `id_embarque`=emb)+1);
            
            INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idNewGasto, emb, 2, (pagoPel*bolsasNum));
            
            CALL actPesosCuenta(emb, (pagoPel*bolsasNum));
         END IF; -- Fin actualizar cunetas y gastos
        
    END IF; -- Fin IF de registro o actualización
    
END$$

DROP PROCEDURE IF EXISTS `updateProd`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateProd` (IN `embarque` INT, IN `idFruta` VARCHAR(25), IN `idPrest` VARCHAR(25), IN `kilos` FLOAT, IN `pago` FLOAT, IN `pagoNew` FLOAT, IN `fun` FLOAT, IN `funNew` FLOAT, IN `fer` FLOAT, IN `ferNew` FLOAT, IN `pres` FLOAT, IN `presNew` FLOAT, IN `aFun` FLOAT, IN `aFunNew` FLOAT, IN `aFer` FLOAT, IN `aFerNew` FLOAT, IN `aPres` FLOAT, IN `aPresNew` FLOAT, IN `noPFu` INT, IN `noPFe` INT, IN `noPP` INT, IN `noPFuN` INT, IN `noPFeN` INT, IN `noPPN` INT)  NO SQL
BEGIN

	IF pago != pagoNew THEN
    	SET @pagoRegis = ((pagoNew-pago)*kilos);
        
        UPDATE fruta SET fruta.pago=pagoNew, fruta.saldo_abono=fruta.saldo_abono+@pagoRegis WHERE fruta.id=idFruta;
        
        -- Actualizar Gastos
        CALL actEmbarquesSiguientes(embarque, 1, @pagoRegis);
    
    END IF;
    
-- =====================================================================================0

    IF fun != funNew OR fer != ferNew OR pres != presNew THEN
    
    	IF idPrest>0 THEN
    	-- Registro de Prestamos
            SET @funReg= (funNew-fun);
            SET @ferReg= (ferNew-fer);
            SET @presReg= (presNew-pres);
            
            SET @regPFun=(noPFuN-noPFu);
            SET @regPFer=(noPFeN-noPFe);
            SET @regPPre=(noPPN-noPP);
            
            SET @regAbonFun=(aFunNew-aFun);
            SET @regAbonFer=(aFerNew-aFer);
            SET @regAbonPre=(aPresNew-aPres);

            UPDATE prestamos SET prestamos.fungicida=prestamos.fungicida+@funReg, prestamos.fertilizante=prestamos.fertilizante+@ferReg, prestamos.prestamo=prestamos.prestamo+@presReg, prestamos.no_pagos_fungicida=prestamos.no_pagos_fungicida+@regPFun , prestamos.no_pagos_fertilizante=prestamos.no_pagos_fertilizante+@regPFer, prestamos.no_pagos_prestamo=prestamos.no_pagos_prestamo+@regPPre, prestamos.abono_fungicida=prestamos.abono_fungicida+(@regAbonFun),
prestamos.abono_fertilizante=prestamos.abono_fertilizante+(@regAbonFer),
prestamos.abono_prestamo=prestamos.abono_prestamo+(@regAbonPre), prestamos.saldo_fungicida=(prestamos.fungicida-prestamos.abono_fungicida), prestamos.saldo_fertilizante=(prestamos.fertilizante-prestamos.abono_fertilizante), prestamos.saldo_prestamo=(prestamos.prestamo-prestamos.abono_prestamo), prestamos.abono_cantidad_fungicida=IFNULL((prestamos.fungicida / prestamos.no_pagos_fungicida),0), prestamos.abono_cantidad_fertilizante=IFNULL((prestamos.fertilizante / prestamos.no_pagos_fertilizante),0), prestamos.abono_cantidad_prestamo=IFNULL((prestamos.prestamo / prestamos.no_pagos_prestamo),0) WHERE prestamos.id=idPrest;

            -- Actualizar gastos segun el tipo de Gasto
            
            IF aFunNew <> aFun THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-@regAbonFun) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=29);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@regAbonFun) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 29, @regAbonFun);
                END IF;
            END IF;
            
            IF aFerNew<>aFer THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-@regAbonFer) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=23);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@regAbonFer) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 23, @regAbonFer);
                END IF;
                
            END IF;
            
            IF aPresNew<>aPres THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-@regAbonPre) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=24);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+@regAbonPre) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 24, @regAbonPre);
                END IF;
                
            END IF;
            
-- ===========================================================================

       	ELSE
        SET @productorId = (SELECT fruta.id_productores FROM fruta WHERE fruta.id=idFruta);
        SET @idNew = CONCAT(embarque, @productorId);
        
        INSERT INTO `prestamos`(`id`, `id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNew, idFruta, funNew, ferNew, presNew, noPFuN, noPFeN, noPPN, aFunNew, aFerNew, aPresNew, (funNew-aFunNew), (ferNew-aFerNew), (presNew-aPresNew), (funNew-noPFuN), (ferNew-noPFeN), (presNew-noPPN) );
        
        -- Actualizar Gastos
        	
            IF aFunNew>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-aFunNew) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=29);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+aFunNew) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 29, aFunNew);
                END IF;
                
            END IF;
        	
            IF aFerNew>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-aFerNew) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=23);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+aFerNew) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 23, aFerNew);
                END IF;
                
            END IF;
        
        	
            IF aPresNew>0 THEN
            	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-aPresNew) WHERE `id_embarque`=embarque AND `id_gasto`=1;
                
                SET @buscGastAbono=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=24);
                
                IF @buscGastAbono>0 THEN
                    UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`+aPresNew) WHERE `id`=@buscGastAbono;
                ELSE
                    SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
                    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 24, aPresNew);
                END IF;
                
            END IF;
            
        END IF;
    	
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `update_bolseros`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_bolseros` (IN `op` INT(11), IN `embarque` INT(11), IN `dia1` FLOAT, IN `dia2` FLOAT, IN `dia3` FLOAT, IN `dia4` FLOAT, IN `dia5` FLOAT, IN `id` INT)  BEGIN
# op1= MODIFICAR pagos
# op2= ELIMINAR pagos
# op3= AGREGAR bolseros a la tabla para luego insertar pagos

set @emb=embarque;

#==========UPDATE========
IF op=1 THEN
	#Actualizamos la tabla bolsas pelador y el total con los nuevos datos
    set @total=(dia1+dia2+dia3+dia4+dia5);
    	SET @pagoAnt=(SELECT SUM(bolsas_bolsero.pago_bol) from bolsas_bolsero WHERE bolsas_bolsero.id_embarque=embarque and bolsas_bolsero.id_bolsero=id);
        SET @cantidadNew=@total-@pagoAnt;
        
	UPDATE bolsas_bolsero SET bolsas_bolsero.diaUno=dia1, bolsas_bolsero.diaDos=dia2, bolsas_bolsero.diaTres=dia3, bolsas_bolsero.diaCuatro=dia4, bolsas_bolsero.diaCinco=dia5, bolsas_bolsero.pago_bol=@total where bolsas_bolsero.id_embarque=embarque AND bolsas_bolsero.id_bolsero=id;
 
 -- Actualizar Gastos (Tipo Bolsero 3) de embarque, gastos_embarque y cuenta pesos
 SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            
 UPDATE `embarque` as e SET e.total_gastos=e.total_gastos+@cantidadNew WHERE id=@emb;
            
            
	IF @buscGastPT>0 THEN
    	UPDATE gastos_embarque ge SET ge.cantidad=(ge.cantidad+@cantidadNew) WHERE ge.id_embarque=embarque and ge.id_gasto=3;
	ELSE
		SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, @cantidadNew);
	END IF;
CALL actPesosCuenta(embarque, @cantidadNew);

#========DELETE============
ELSEIF op=2 then 

SET @pagoAnt=(SELECT SUM(bolsas_bolsero.pago_bol) from bolsas_bolsero WHERE bolsas_bolsero.id_embarque=embarque and bolsas_bolsero.id_bolsero=id);

	UPDATE bolsas_bolsero SET bolsas_bolsero.fecha_trabajo_bol='', bolsas_bolsero.diaUno=0,bolsas_bolsero.diaDos=0,bolsas_bolsero.diaTres=0, bolsas_bolsero.diaCuatro=0,bolsas_bolsero.diaCinco=0, bolsas_bolsero.pago_bol=0 where bolsas_bolsero.id_bolsero=id and bolsas_bolsero.id_embarque=embarque;
    
    -- Actualizar Gastos (Tipo Bolsero 3) de embarque, gastos_embarque y cuenta pesos
            SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
            
            UPDATE `embarque` as e SET e.total_gastos=(e.total_gastos-@pagoAnt) WHERE id=@emb;
            
            IF @buscGastPT>0 THEN
                UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-@pagoAnt) WHERE `id`=@buscGastPT;
          
            END IF;
            CALL actPesosCuenta(embarque,-@pagoAnt); 
    
#========INSERT============
ELSEIF op=3 THEN
#Buscamos si ya está registrado el trabajador
set @busca=(SELECT COUNT(bolsas_bolsero.id) from bolsas_bolsero where bolsas_bolsero.id_bolsero=id and bolsas_bolsero.id_embarque=embarque);
	IF @busca=0 then 
   #Generamos un id para la tabla
   set @idB=CONCAT(embarque, (SELECT COUNT(id) FROM bolsas_bolsero WHERE id_embarque=embarque)+1);
		INSERT INTO bolsas_bolsero(bolsas_bolsero.id, bolsas_bolsero.id_bolsero, bolsas_bolsero.id_embarque, bolsas_bolsero.fecha_trabajo_bol, bolsas_bolsero.diaUno, bolsas_bolsero.diaDos,bolsas_bolsero.diaTres, bolsas_bolsero.diaCuatro, bolsas_bolsero.diaCinco, bolsas_bolsero.pago_bol) VALUES(@idB,id, embarque,'',0,0,0,0,0,0);
	END IF;
END IF;
END$$

DROP PROCEDURE IF EXISTS `update_pesos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_pesos` (IN `id_e` INT, IN `cant` FLOAT)  NO SQL
    COMMENT 'Actualizar el saldo total cada que se actualice gastos_embarque'
BEGIN
	set @exist=(SELECT pesos.id FROM pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id WHERE cuenta_pesos.id_emb= id_e ORDER BY pesos.id DESC LIMIT 1);
    
    set @id_cuenta=(select id_cuenta from pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id where cuenta_pesos.id_emb=id_e ORDER BY pesos.id_cuenta desc LIMIT 1);
    
    
    	UPDATE pesos SET gastos_embarque=gastos_embarque+cant where pesos.id=@exist;
    	UPDATE cuenta_pesos SET cuenta_pesos.total_egreso=cuenta_pesos.total_egreso+cant where cuenta_pesos.id_emb=id_e;
    	UPDATE cuenta_pesos SET cuenta_pesos.total_saldo= cuenta_pesos.total_saldo-cant where cuenta_pesos.id_emb=id_e;
    
    
    
END$$

DROP PROCEDURE IF EXISTS `update_planilla`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_planilla` (IN `op` INT, IN `embarque` INT, IN `dia1` FLOAT, IN `dia2` FLOAT, IN `dia3` FLOAT, IN `dia4` FLOAT, IN `dia5` FLOAT, IN `idPlanilla` INT, IN `idP` INT, IN `fech` DATE)  NO SQL
BEGIN
#op 1= actualizar pago de planilla
set @emb=embarque;
#===========UPDATE==========
IF op=1 THEN
    #Actualizamos la tabla bolsas pelador y el total con los nuevos datos
    set @total=(dia1+dia2+dia3+dia4+dia5);
    
    SET @pagoAnt=(SELECT SUM(bolsas_toston.pago) from bolsas_toston WHERE bolsas_toston.id_embarque=embarque AND bolsas_toston.id_planilla=idP);
    
    set @cantidadNew=@total-@pagoAnt;
                      
    UPDATE bolsas_toston SET bolsas_toston.diaUno=dia1, bolsas_toston.diaDos=dia2, bolsas_toston.diaTres=dia3, bolsas_toston.diaCuatro=dia4, bolsas_toston.diaCinco=dia5, bolsas_toston.pago=@total where bolsas_toston.id_embarque=embarque AND bolsas_toston.id_planilla=idP;
    
    -- Actualizar Gastos (Tipo Bolsero 3) de embarque, gastos_embarque y cuenta pesos
    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
        
    UPDATE `embarque` as e SET e.total_gastos=e.total_gastos-@cantidadNew WHERE id=@emb;
    
    IF @buscGastPT>0 THEN
        UPDATE gastos_embarque ge SET ge.cantidad=(ge.cantidad+@cantidadNew) WHERE ge.id_embarque=embarque AND ge.id_gasto=4;
    ELSE
        SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
        INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 4, @cantidadNew);
    END IF;
    
    CALL actPesosCuenta(embarque, @cantidadNew);
    
    #===========DELETE============
ELSEIF op=2 then 
#Seleccionamos el pago anterior de la planilla segun su id y el embarque
    SET @pagoAntP=(select bolsas_toston.pago from bolsas_toston where bolsas_toston.id_planilla=idP and bolsas_toston.id_embarque=embarque);
    
    UPDATE bolsas_toston SET bolsas_toston.fecha='', bolsas_toston.diaUno=0, bolsas_toston.diaDos=0, bolsas_toston.diaTres=0, bolsas_toston.diaCuatro=0, bolsas_toston.diaCinco=0, bolsas_toston.pago=0 where bolsas_toston.id_planilla=idP and bolsas_toston.id_embarque=embarque;
    
    -- Actualizar Gastos (Tipo Bolsero 3) de embarque, gastos_embarque y cuenta pesos
    SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=4);
    
    UPDATE `embarque` as e SET e.total_gastos=e.total_gastos-@pagoAntP WHERE id=@emb;
    
    IF @buscGastPT>0 THEN
        UPDATE gastos_embarque ge SET ge.cantidad=(ge.cantidad-@pagoAntP) WHERE ge.id_embarque=embarque AND ge.id_gasto=4;
    END IF;
    CALL actPesosCuenta(embarque,- @pagoAntP);
#=========Agregar=============

ELSEIF op=3 THEN
#Buscamos si ya está registrado el trabajador
set @busca=(SELECT COUNT(bolsas_toston.id) from bolsas_toston where bolsas_toston.id_planilla=idP and bolsas_toston.id_embarque=embarque);
    IF @busca=0 then 
        #Generamos un id para la tabla
        set @idB=CONCAT(embarque, (SELECT COUNT(id) FROM bolsas_toston WHERE id_embarque=embarque)+1);
        
        INSERT INTO bolsas_toston(id, id_planilla, id_embarque, fecha, diaUno, diaDos, diaTres, diaCuatro, diaCinco, pago) VALUES(@idB,idP, embarque, fech, 0,0,0,0,0,0);
    END IF;
END IF;
END$$

DROP PROCEDURE IF EXISTS `verEmb`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmb` (IN `id_e` INT)  NO SQL
SELECT `id`, DATE_ADD(fecha_inicio, INTERVAL dia_actual DAY) as fecha_inicio, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, toneladas FROM `embarque` WHERE id =id_e$$

DROP PROCEDURE IF EXISTS `verEmbarque`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmbarque` ()  NO SQL
SELECT id, fecha_inicio, cant_bolsas_embarque FROM embarque WHERE fecha_fin='0000-00-00' ORDER BY id ASC$$

DROP PROCEDURE IF EXISTS `verListaB`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaB` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

DROP PROCEDURE IF EXISTS `verListaGBolseros`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGBolseros` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

DROP PROCEDURE IF EXISTS `verListaGPeladores`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGPeladores` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

DROP PROCEDURE IF EXISTS `verListaOProd`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaOProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m` FROM `productores` ORDER BY id ASC$$

DROP PROCEDURE IF EXISTS `verListaP`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaP` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

DROP PROCEDURE IF EXISTS `verListaProd`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `foto` FROM `productores`$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas`
--

DROP TABLE IF EXISTS `bolsas`;
CREATE TABLE `bolsas` (
  `id` varchar(11) CHARACTER SET latin1 NOT NULL,
  `id_cuenta` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `concepto` varchar(50) NOT NULL,
  `ingreso` double(10,2) DEFAULT 0.00,
  `egreso` double(10,2) DEFAULT 0.00,
  `saldo` double(10,2) NOT NULL,
  `activo` int(2) DEFAULT 0,
  `mostrar` int(2) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas`
--

INSERT INTO `bolsas` (`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `activo`, `mostrar`) VALUES
('1001', '1001', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1011', '1011', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1021', '1021', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1031', '1031', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1041', '1041', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1051', '1051', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1061', '1061', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1071', '1071', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1081', '1081', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1091', '1091', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1101', '1101', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1111', '1111', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1121', '1121', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1131', '1131', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1141', '1141', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1151', '1151', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1161', '1161', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1171', '1171', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('1172', '1171', 'COMPRA BOLSAS', 1000.00, 0.00, 2552.83, 1, 1),
('1181', '1181', 'SALDO ANTERIOR', 0.00, 0.00, 2552.83, 0, 1),
('1191', '1191', 'SALDO ANTERIOR', 0.00, 0.00, 2552.83, 0, 1),
('1201', '1201', 'SALDO ANTERIOR', 0.00, 0.00, 2552.83, 0, 1),
('1211', '1211', 'SALDO ANTERIOR', 0.00, 0.00, 2552.83, 0, 1),
('1221', '1221', 'SALDO ANTERIOR', 0.00, 0.00, 2552.83, 0, 1),
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 222.17, 0, 1),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 222.17, 0, 1),
('772', '771', 'COMPRA DE BOLSAS E77', 498.50, 0.00, 720.67, 0, 1),
('773', '771', 'EMBARQUE 77', 0.00, 88.20, 632.47, 1, 1),
('774', '772', 'SALDO ANTERIOR', 0.00, 0.00, 632.47, 0, 1),
('782', '772', 'EMBARQUE 78', 0.00, 87.00, 545.47, 1, 1),
('783', '782', 'SALDO ANTERIOR', 0.00, 0.00, 545.47, 0, 1),
('792', '782', 'EMBARQUE 79', 0.00, 85.90, 459.57, 1, 1),
('793', '792', 'SALDO ANTERIOR', 0.00, 0.00, 459.57, 0, 1),
('802', '792', 'EMBARQUE 80', 0.00, 82.00, 377.57, 1, 1),
('803', '802', 'SALDO ANTERIOR', 0.00, 0.00, 377.57, 0, 1),
('812', '802', 'EMBARQUE 81', 0.00, 63.00, 314.57, 1, 1),
('813', '812', 'SALDO ANTERIOR', 0.00, 0.00, 314.57, 0, 1),
('822', '812', 'EMBARQUE 81', 0.00, 83.00, 231.57, 1, 1),
('831', '831', 'SALDO ANTERIOR', 0.00, 0.00, 231.57, 0, 1),
('832', '831', 'EMBARQUE 83', 0.00, 86.00, 145.57, 1, 1),
('841', '841', 'SALDO ANTERIOR', 0.00, 0.00, 145.57, 0, 1),
('842', '841', 'EMBARQUE 84', 0.00, 88.00, 57.57, 1, 1),
('851', '851', 'SALDO ANTERIOR', 0.00, 0.00, 655.00, 0, 1),
('852', '851', 'GASTO E85', 0.00, 84.30, 570.70, 1, 1),
('861', '861', 'SALDO ANTERIOR', 0.00, 0.00, 570.70, 0, 1),
('862', '861', 'GASTO E86', 0.00, 93.00, 477.70, 1, 1),
('871', '871', 'SALDO ANTERIOR', 0.00, 0.00, 570.70, 0, 1),
('872', '871', 'GASTO E86', 0.00, 93.00, 477.70, 1, 1),
('881', '881', 'SALDO ANTERIOR', 0.00, 0.00, 374.25, 0, 1),
('882', '881', 'GASTO E87', 0.00, 111.00, 263.25, 1, 1),
('891', '891', 'SALDO ANTERIOR', 0.00, 0.00, 263.25, 0, 1),
('892', '891', 'GASTO E89', 0.00, 82.00, 181.25, 1, 1),
('901', '901', 'SALDO ANTERIOR', 0.00, 0.00, 263.25, 0, 1),
('902', '901', 'GASTO E89', 0.00, 82.00, 181.25, 1, 1),
('911', '911', 'SALDO ANTERIOR', 0.00, 0.00, 141.00, 0, 1),
('912', '911', 'COMPRA BOLSAS', 1496.70, 0.00, 1637.70, 1, 1),
('913', '911', 'GASTO E91', 0.00, 84.87, 1593.08, 1, 1),
('921', '921', 'SALDO ANTERIOR', 0.00, 0.00, 1637.70, 0, 1),
('922', '921', 'GASTO E89', 0.00, 84.87, 1552.83, 1, 1),
('931', '931', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('941', '941', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('951', '951', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('961', '961', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('971', '971', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('981', '981', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1),
('991', '991', 'SALDO ANTERIOR', 0.00, 0.00, 1552.83, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_bolsero`
--

DROP TABLE IF EXISTS `bolsas_bolsero`;
CREATE TABLE `bolsas_bolsero` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_bolsero` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha_trabajo_bol` date NOT NULL,
  `diaUno` float(10,2) DEFAULT 0.00,
  `diaDos` float(10,2) DEFAULT 0.00,
  `diaTres` float(10,2) DEFAULT 0.00,
  `diaCuatro` float(10,2) DEFAULT 0.00,
  `diaCinco` float(10,2) DEFAULT 0.00,
  `cantidad_bolsas_bol` int(11) DEFAULT 0,
  `pago_bol` float NOT NULL,
  `estra` int(2) DEFAULT 0,
  `actividad` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas_bolsero`
--

INSERT INTO `bolsas_bolsero` (`id`, `id_bolsero`, `id_embarque`, `fecha_trabajo_bol`, `diaUno`, `diaDos`, `diaTres`, `diaCuatro`, `diaCinco`, `cantidad_bolsas_bol`, `pago_bol`, `estra`, `actividad`) VALUES
('1001', 1, 100, '2020-08-17', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1002', 9, 100, '2020-08-17', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1003', 5, 100, '2020-08-17', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1004', 8, 100, '2020-08-17', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1005', 3, 100, '2020-08-17', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1006', 6, 100, '2020-08-17', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1007', 2, 100, '2020-08-17', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1008', 4, 100, '2020-08-17', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1011', 1, 101, '2020-08-18', 2300.00, 0.00, 0.00, 0.00, 0.00, 0, 2300, 0, NULL),
('1012', 7, 101, '2020-08-18', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1013', 9, 101, '2020-08-18', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1014', 5, 101, '2020-08-18', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1015', 8, 101, '2020-08-18', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1016', 3, 101, '2020-08-18', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1017', 6, 101, '2020-08-18', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1018', 2, 101, '2020-08-18', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1019', 4, 101, '2020-08-18', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1021', 1, 102, '2020-08-19', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('10210', 10, 102, '2020-08-19', 500.00, 0.00, 0.00, 0.00, 0.00, 0, 500, 0, NULL),
('1022', 7, 102, '2020-08-19', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1023', 9, 102, '2020-08-19', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1024', 5, 102, '2020-08-19', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1025', 8, 102, '2020-08-19', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1026', 3, 102, '2020-08-19', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1027', 6, 102, '2020-08-19', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1028', 2, 102, '2020-08-19', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1029', 4, 102, '2020-08-19', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1031', 1, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1032', 7, 103, '2020-08-20', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1033', 9, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1034', 5, 103, '2020-08-20', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1035', 8, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1036', 3, 103, '2020-08-20', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1037', 6, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1038', 4, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1039', 10, 103, '2020-08-20', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1041', 1, 104, '2020-08-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1042', 7, 104, '2020-08-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1043', 9, 104, '2020-08-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1044', 8, 104, '2020-08-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1045', 3, 104, '2020-08-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1046', 6, 104, '2020-08-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1047', 2, 104, '2020-08-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1048', 4, 104, '2020-08-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1049', 5, 104, '2020-08-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1051', 1, 105, '2020-08-24', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1052', 7, 105, '2020-08-24', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1053', 9, 105, '2020-08-24', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1054', 5, 105, '2020-08-24', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1055', 8, 105, '2020-08-24', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1056', 3, 105, '2020-08-24', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1057', 6, 105, '2020-08-24', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1058', 2, 105, '2020-08-24', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1061', 1, 106, '2020-08-31', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1062', 7, 106, '2020-08-31', 1800.00, 0.00, 0.00, 0.00, 0.00, 0, 1800, 0, NULL),
('1063', 9, 106, '2020-08-31', 550.00, 0.00, 0.00, 0.00, 0.00, 0, 550, 0, NULL),
('1064', 5, 106, '2020-08-31', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1065', 8, 106, '2020-08-31', 1100.00, 0.00, 0.00, 0.00, 0.00, 0, 1100, 0, NULL),
('1066', 3, 106, '2020-08-31', 1100.00, 0.00, 0.00, 0.00, 0.00, 0, 1100, 0, NULL),
('1067', 6, 106, '2020-08-31', 550.00, 0.00, 0.00, 0.00, 0.00, 0, 550, 0, NULL),
('1068', 2, 106, '2020-08-31', 1100.00, 0.00, 0.00, 0.00, 0.00, 0, 1100, 0, NULL),
('1069', 4, 106, '2020-08-31', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1071', 1, 107, '2020-09-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1072', 7, 107, '2020-09-07', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1073', 9, 107, '2020-09-07', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1074', 5, 107, '2020-09-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1075', 8, 107, '2020-09-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1076', 3, 107, '2020-09-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1077', 6, 107, '2020-09-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1078', 2, 107, '2020-09-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1079', 4, 107, '2020-09-07', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1081', 1, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1082', 7, 108, '2020-09-12', 1600.00, 0.00, 0.00, 0.00, 0.00, 0, 1600, 0, NULL),
('1083', 9, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1084', 5, 108, '2020-09-12', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1085', 8, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1086', 3, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1087', 6, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1088', 2, 108, '2020-09-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1091', 1, 109, '2020-09-14', 1300.00, 0.00, 0.00, 0.00, 0.00, 0, 1300, 0, NULL),
('10910', 2, 109, '2020-09-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1092', 7, 109, '2020-09-14', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1093', 9, 109, '2020-09-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1094', 5, 109, '2020-09-14', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1095', 11, 109, '2020-09-14', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('1096', 12, 109, '2020-09-14', 200.00, 0.00, 0.00, 0.00, 0.00, 0, 200, 0, NULL),
('1097', 8, 109, '2020-09-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1098', 3, 109, '2020-09-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1099', 6, 109, '2020-09-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1101', 1, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1102', 7, 110, '2020-09-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1103', 9, 110, '2020-09-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1104', 5, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1105', 8, 110, '2020-09-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1106', 3, 110, '2020-09-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1107', 6, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1108', 2, 110, '2020-09-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1109', 4, 110, '2020-09-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1111', 1, 111, '2020-09-28', 1100.00, 0.00, 0.00, 0.00, 0.00, 0, 1100, 0, NULL),
('1112', 7, 111, '2020-09-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1113', 9, 111, '2020-09-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1114', 5, 111, '2020-09-28', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1115', 8, 111, '2020-09-28', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1116', 3, 111, '2020-09-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1117', 6, 111, '2020-09-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1118', 2, 111, '2020-09-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1119', 4, 111, '2020-09-28', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1121', 1, 112, '2020-10-05', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1122', 7, 112, '2020-10-05', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1123', 9, 112, '2020-10-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1124', 5, 112, '2020-10-05', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1125', 8, 112, '2020-10-05', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1126', 3, 112, '2020-10-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1127', 6, 112, '2020-10-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1128', 2, 112, '2020-10-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1129', 4, 112, '2020-10-05', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1131', 7, 113, '2020-10-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('11310', 16, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1132', 15, 113, '2020-10-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1133', 5, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1134', 11, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1135', 12, 113, '2020-10-12', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1136', 14, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1137', 8, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1138', 3, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1139', 2, 113, '2020-10-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1141', 1, 114, '2020-10-07', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('11410', 3, 114, '2020-10-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11411', 2, 114, '2020-10-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11412', 16, 114, '2020-10-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11413', 6, 114, '2020-10-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1142', 7, 114, '2020-10-07', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1143', 9, 114, '2020-10-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1144', 15, 114, '2020-10-07', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1145', 5, 114, '2020-10-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1146', 11, 114, '2020-10-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1147', 12, 114, '2020-10-07', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1148', 14, 114, '2020-10-07', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1149', 8, 114, '2020-10-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1151', 1, 115, '2020-10-14', 700.00, 0.00, 0.00, 0.00, 0.00, 0, 700, 0, NULL),
('11510', 3, 115, '2020-10-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('11511', 6, 115, '2020-10-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('11512', 2, 115, '2020-10-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('11513', 4, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('11514', 17, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('11515', 19, 115, '2020-10-14', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1152', 7, 115, '2020-10-14', 1900.00, 0.00, 0.00, 0.00, 0.00, 0, 1900, 0, NULL),
('1153', 9, 115, '2020-10-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1154', 15, 115, '2020-10-14', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1155', 5, 115, '2020-10-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1156', 11, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1157', 12, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1158', 14, 115, '2020-10-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1159', 16, 115, '2020-10-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('1161', 1, 116, '2020-10-21', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('11610', 3, 116, '2020-10-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11611', 19, 116, '2020-10-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('11612', 6, 116, '2020-10-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('11613', 2, 116, '2020-10-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11614', 4, 116, '2020-10-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('11615', 20, 116, '2020-10-21', 200.00, 0.00, 0.00, 0.00, 0.00, 0, 200, 0, NULL),
('11616', 21, 116, '2020-10-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1162', 7, 116, '2020-10-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1163', 9, 116, '2020-10-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1164', 5, 116, '2020-10-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1165', 15, 116, '2020-10-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1166', 11, 116, '2020-10-21', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1167', 12, 116, '2020-10-21', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1168', 14, 116, '2020-10-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1169', 16, 116, '2020-10-21', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1171', 1, 117, '2020-10-28', 1100.00, 0.00, 0.00, 0.00, 0.00, 0, 1100, 0, NULL),
('11710', 3, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11711', 6, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('11712', 2, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1172', 7, 117, '2020-10-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1173', 9, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1174', 15, 117, '2020-10-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1175', 5, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1176', 11, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1177', 12, 117, '2020-10-28', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1178', 14, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1179', 16, 117, '2020-10-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('1181', 1, 118, '2020-11-04', 0.00, 400.00, 400.00, 400.00, 0.00, 0, 1200, 0, NULL),
('11810', 14, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('11811', 16, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('11812', 4, 118, '0000-00-00', 0.00, 0.00, 0.00, 300.00, 0.00, 0, 300, 0, NULL),
('11813', 15, 118, '0000-00-00', 0.00, 1500.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1182', 2, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1183', 3, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1184', 5, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1185', 6, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1186', 7, 118, '2020-11-04', 300.00, 400.00, 400.00, 400.00, 0.00, 0, 1500, 0, NULL),
('1187', 9, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1188', 11, 118, '2020-11-04', 0.00, 300.00, 300.00, 300.00, 0.00, 0, 900, 0, NULL),
('1189', 12, 118, '2020-11-04', 0.00, 300.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('1191', 1, 119, '0000-00-00', 0.00, 0.00, 300.00, 400.00, 300.00, 0, 1000, 0, NULL),
('11910', 3, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('11911', 6, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('11912', 2, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('11913', 13, 119, '0000-00-00', 0.00, 0.00, 0.00, 0.00, 150.00, 0, 150, 0, NULL),
('1192', 7, 119, '0000-00-00', 0.00, 300.00, 0.00, 400.00, 400.00, 0, 1100, 0, NULL),
('1193', 9, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('1194', 15, 119, '0000-00-00', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1195', 5, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 0.00, 0, 600, 0, NULL),
('1196', 11, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('1197', 12, 119, '0000-00-00', 0.00, 0.00, 100.00, 100.00, 0.00, 0, 200, 0, NULL),
('1198', 14, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('1199', 16, 119, '0000-00-00', 0.00, 0.00, 300.00, 300.00, 300.00, 0, 900, 0, NULL),
('1201', 1, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('12010', 2, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('12011', 5, 120, '2020-11-26', 300.00, 300.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('12012', 15, 120, '0000-00-00', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('12013', 19, 120, '0000-00-00', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('12014', 22, 120, '0000-00-00', 200.00, 0.00, 0.00, 0.00, 0.00, 0, 200, 0, NULL),
('1202', 7, 120, '2020-11-26', 300.00, 400.00, 400.00, 400.00, 0.00, 0, 1500, 0, NULL),
('1203', 9, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1204', 14, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1205', 6, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1206', 3, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1207', 16, 120, '2020-11-26', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1208', 11, 120, '2020-11-26', 300.00, 300.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1209', 12, 120, '2020-11-26', 100.00, 100.00, 100.00, 0.00, 0.00, 0, 300, 0, NULL),
('1211', 1, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('12110', 3, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('12111', 6, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('12112', 2, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1212', 7, 121, '2020-11-30', 300.00, 400.00, 400.00, 400.00, 0.00, 0, 1500, 0, NULL),
('1213', 9, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1214', 15, 121, '2020-11-30', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('1215', 5, 121, '2020-11-30', 300.00, 300.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('1216', 11, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1217', 12, 121, '2020-11-30', 100.00, 100.00, 0.00, 0.00, 0.00, 0, 200, 0, NULL),
('1218', 14, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('1219', 16, 121, '2020-11-30', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('771', 1, 77, '2020-07-25', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('7710', 13, 77, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('7711', 8, 77, '2020-07-25', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('772', 7, 77, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('773', 9, 77, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('774', 3, 77, '2020-07-25', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('775', 5, 77, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('776', 11, 77, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('777', 12, 77, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('778', 2, 77, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('779', 6, 77, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('781', 1, 78, '2020-07-25', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('7810', 6, 78, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('782', 7, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('783', 9, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('784', 3, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('785', 5, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('786', 11, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('787', 12, 78, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('788', 2, 78, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('789', 8, 78, '2020-07-25', 200.00, 0.00, 0.00, 0.00, 0.00, 0, 200, 0, NULL),
('791', 1, 79, '2020-07-25', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('792', 7, 79, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('793', 4, 79, '2020-07-25', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('794', 3, 79, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('795', 5, 79, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('796', 9, 79, '2020-07-25', 70.00, 0.00, 0.00, 0.00, 0.00, 0, 70, 0, NULL),
('797', 6, 79, '2020-07-25', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('801', 1, 80, '2020-07-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('802', 7, 80, '2020-07-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('803', 4, 80, '2020-07-28', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('804', 3, 80, '2020-07-28', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('805', 5, 80, '2020-07-28', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('806', 9, 80, '2020-07-28', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('807', 6, 80, '2020-07-28', 250.00, 0.00, 0.00, 0.00, 0.00, 0, 250, 0, NULL),
('811', 1, 81, '2020-07-29', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('812', 7, 81, '2020-07-29', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('813', 4, 81, '2020-07-29', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('814', 3, 81, '2020-07-29', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('815', 5, 81, '2020-07-29', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('821', 1, 82, '2020-07-30', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('822', 7, 82, '2020-07-30', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('823', 4, 82, '2020-07-30', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('824', 3, 82, '2020-07-30', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('825', 5, 82, '2020-07-30', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('826', 6, 82, '2020-07-30', 350.00, 0.00, 0.00, 0.00, 0.00, 0, 350, 0, NULL),
('827', 9, 82, '2020-07-30', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('828', 2, 82, '2020-07-30', 150.00, 0.00, 0.00, 0.00, 0.00, 0, 150, 0, NULL),
('831', 1, 83, '2020-07-31', 1400.00, 0.00, 0.00, 0.00, 0.00, 0, 1400, 0, NULL),
('832', 7, 83, '2020-07-31', 850.00, 0.00, 0.00, 0.00, 0.00, 0, 850, 0, NULL),
('833', 4, 83, '2020-07-31', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('834', 5, 83, '2020-07-31', 1150.00, 0.00, 0.00, 0.00, 0.00, 0, 1150, 0, NULL),
('835', 6, 83, '2020-07-31', 850.00, 0.00, 0.00, 0.00, 0.00, 0, 850, 0, NULL),
('836', 9, 83, '2020-07-31', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('837', 2, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('841', 1, 84, '2020-08-01', 1150.00, 0.00, 0.00, 0.00, 0.00, 0, 1150, 0, NULL),
('842', 7, 84, '2020-08-01', 1800.00, 0.00, 0.00, 0.00, 0.00, 0, 1800, 0, NULL),
('843', 4, 84, '2020-08-01', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('844', 5, 84, '2020-08-01', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('845', 6, 84, '2020-08-01', 850.00, 0.00, 0.00, 0.00, 0.00, 0, 850, 0, NULL),
('846', 9, 84, '2020-08-01', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('847', 8, 84, '2020-08-01', 350.00, 0.00, 0.00, 0.00, 0.00, 0, 350, 0, NULL),
('848', 3, 84, '2020-08-01', 1000.00, 0.00, 0.00, 0.00, 0.00, 0, 1000, 0, NULL),
('851', 2, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('852', 6, 85, '2020-08-02', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('853', 5, 85, '2020-08-02', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('854', 4, 85, '2020-08-02', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('855', 7, 85, '2020-08-02', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('856', 1, 85, '2020-08-02', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('861', 1, 86, '2020-08-03', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('862', 7, 86, '2020-08-03', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('863', 4, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('864', 3, 86, '2020-08-03', 1000.00, 0.00, 0.00, 0.00, 0.00, 0, 1000, 0, NULL),
('865', 5, 86, '2020-08-03', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('866', 8, 86, '2020-08-03', 700.00, 0.00, 0.00, 0.00, 0.00, 0, 700, 0, NULL),
('867', 2, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('871', 1, 87, '2020-08-04', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('872', 7, 87, '2020-08-04', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('873', 4, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('874', 3, 87, '2020-08-04', 1000.00, 0.00, 0.00, 0.00, 0.00, 0, 1000, 0, NULL),
('875', 5, 87, '2020-08-04', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('876', 8, 87, '2020-08-04', 700.00, 0.00, 0.00, 0.00, 0.00, 0, 700, 0, NULL),
('877', 2, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('881', 1, 88, '2020-08-05', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('882', 7, 88, '2020-08-05', 1800.00, 0.00, 0.00, 0.00, 0.00, 0, 1800, 0, NULL),
('883', 9, 88, '2020-08-05', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('884', 5, 88, '2020-08-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('885', 8, 88, '2020-08-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('886', 4, 88, '2020-08-05', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('887', 2, 88, '2020-08-05', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('891', 1, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('892', 7, 89, '2020-08-06', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('893', 9, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('894', 5, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('895', 8, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('896', 2, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('897', 6, 89, '2020-08-06', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('901', 1, 90, '2020-08-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('902', 7, 90, '2020-08-07', 700.00, 0.00, 0.00, 0.00, 0.00, 0, 700, 0, NULL),
('903', 9, 90, '2020-08-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('904', 5, 90, '2020-08-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('905', 8, 90, '2020-08-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('906', 3, 90, '2020-08-07', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('907', 6, 90, '2020-08-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('908', 2, 90, '2020-08-07', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('911', 1, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('912', 7, 91, '2020-08-08', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('913', 9, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('914', 5, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('915', 8, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 0, 300, 0, NULL),
('916', 3, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('917', 6, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('918', 2, 91, '2020-08-08', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('921', 1, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('922', 7, 92, '2020-08-09', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('923', 9, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('924', 5, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('925', 8, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('926', 6, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('927', 2, 92, '2020-08-09', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('928', 3, 92, '2020-08-09', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('931', 1, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('932', 7, 93, '2020-08-10', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('933', 9, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('934', 5, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('935', 8, 93, '2020-08-10', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('936', 3, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('937', 6, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('938', 2, 93, '2020-08-10', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('941', 1, 94, '2020-08-11', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('942', 7, 94, '2020-08-11', 1700.00, 0.00, 0.00, 0.00, 0.00, 0, 1700, 0, NULL),
('943', 5, 94, '2020-08-11', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('944', 8, 94, '2020-08-11', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('945', 3, 94, '2020-08-11', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('946', 6, 94, '2020-08-11', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('947', 2, 94, '2020-08-11', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('948', 9, 94, '2020-08-11', 800.00, 0.00, 0.00, 0.00, 0.00, 0, 800, 0, NULL),
('951', 1, 95, '2020-08-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('952', 7, 95, '2020-08-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('953', 5, 95, '2020-08-12', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('954', 8, 95, '2020-08-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('955', 3, 95, '2020-08-12', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('956', 6, 95, '2020-08-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('957', 2, 95, '2020-08-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('958', 9, 95, '2020-08-12', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('961', 1, 96, '2020-08-13', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('962', 7, 96, '2020-08-13', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('963', 9, 96, '2020-08-13', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('964', 5, 96, '2020-08-13', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('965', 8, 96, '2020-08-13', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('966', 3, 96, '2020-08-13', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('967', 6, 96, '2020-08-13', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('968', 2, 96, '2020-08-13', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('971', 1, 97, '2020-08-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('972', 7, 97, '2020-08-14', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('973', 9, 97, '2020-08-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('974', 5, 97, '2020-08-14', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('975', 8, 97, '2020-08-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('976', 3, 97, '2020-08-14', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('977', 6, 97, '2020-08-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('978', 2, 97, '2020-08-14', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('981', 1, 98, '2020-08-15', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('982', 7, 98, '2020-08-15', 1200.00, 0.00, 0.00, 0.00, 0.00, 0, 1200, 0, NULL),
('983', 9, 98, '2020-08-15', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('984', 5, 98, '2020-08-15', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('985', 8, 98, '2020-08-15', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('986', 3, 98, '2020-08-15', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('987', 6, 98, '2020-08-15', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('988', 2, 98, '2020-08-15', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('991', 1, 99, '2020-08-16', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('992', 7, 99, '2020-08-16', 1500.00, 0.00, 0.00, 0.00, 0.00, 0, 1500, 0, NULL),
('993', 9, 99, '2020-08-16', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('994', 5, 99, '2020-08-16', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('995', 8, 99, '2020-08-16', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('996', 3, 99, '2020-08-16', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL),
('997', 6, 99, '2020-08-16', 900.00, 0.00, 0.00, 0.00, 0.00, 0, 900, 0, NULL),
('998', 2, 99, '2020-08-16', 600.00, 0.00, 0.00, 0.00, 0.00, 0, 600, 0, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_diarias`
--

DROP TABLE IF EXISTS `bolsas_diarias`;
CREATE TABLE `bolsas_diarias` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `numero` int(5) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `hora` varchar(15) NOT NULL,
  `fecha` date NOT NULL,
  `pelador` int(11) NOT NULL,
  `id_bolsero` varchar(10) NOT NULL,
  `id_productor` int(11) NOT NULL,
  `valor` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_pelador`
--

DROP TABLE IF EXISTS `bolsas_pelador`;
CREATE TABLE `bolsas_pelador` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_pelador` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha_trabajo_pe` date NOT NULL,
  `cantidad_bolsas_pe` int(11) NOT NULL DEFAULT 0,
  `pago_pe` float NOT NULL DEFAULT 0,
  `estado` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas_pelador`
--

INSERT INTO `bolsas_pelador` (`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`, `estado`) VALUES
('1001', 18, 100, '2020-08-17', 57, 1425, 0),
('10010', 83, 100, '2020-08-17', 32, 800, 0),
('10011', 19, 100, '2020-08-17', 34, 850, 0),
('10012', 34, 100, '2020-08-17', 30, 750, 0),
('10013', 32, 100, '2020-08-17', 25, 625, 0),
('10014', 31, 100, '2020-08-17', 27, 675, 0),
('10015', 30, 100, '2020-08-17', 45, 1125, 0),
('10016', 46, 100, '2020-08-17', 6, 150, 0),
('10017', 8, 100, '2020-08-17', 10, 250, 0),
('10018', 4, 100, '2020-08-17', 26, 650, 0),
('10019', 18, 100, '2020-08-17', 22, 550, 0),
('1002', 2, 100, '2020-08-17', 55, 1375, 0),
('10020', 7, 100, '2020-08-17', 19, 475, 0),
('10021', 21, 100, '2020-08-17', 43, 1075, 0),
('10022', 72, 100, '2020-08-17', 23, 575, 0),
('10023', 29, 100, '2020-08-17', 36, 900, 0),
('10024', 24, 100, '2020-08-17', 13, 325, 0),
('10025', 22, 100, '2020-08-17', 21, 525, 0),
('10026', 26, 100, '2020-08-17', 19, 475, 0),
('10027', 7, 100, '2020-08-17', 5, 125, 0),
('10028', 69, 100, '2020-08-17', 15, 375, 0),
('10029', 64, 100, '2020-08-17', 12, 300, 0),
('1003', 1, 100, '2020-08-17', 56, 1400, 0),
('10030', 9, 100, '2020-08-17', 12, 300, 0),
('10031', 27, 100, '2020-08-17', 8, 200, 0),
('1004', 33, 100, '2020-08-17', 35, 875, 0),
('1005', 17, 100, '2020-08-17', 71, 1775, 0),
('1006', 13, 100, '2020-08-17', 40, 1000, 0),
('1007', 54, 100, '2020-08-17', 98, 2450, 0),
('1008', 68, 100, '2020-08-17', 54, 1350, 0),
('1009', 38, 100, '2020-08-17', 32, 800, 0),
('1011', 2, 101, '2020-08-18', 67, 1675, 0),
('10110', 83, 101, '2020-08-18', 24, 600, 0),
('10111', 46, 101, '2020-08-18', 8, 200, 0),
('10112', 21, 101, '2020-08-18', 54, 1350, 0),
('10113', 24, 101, '2020-08-18', 19, 475, 0),
('10114', 22, 101, '2020-08-18', 26, 650, 0),
('10115', 13, 101, '2020-08-18', 46, 1150, 0),
('10116', 31, 101, '2020-08-18', 29, 725, 0),
('10117', 72, 101, '2020-08-18', 23, 575, 0),
('10118', 19, 101, '2020-08-18', 80, 2000, 0),
('10119', 18, 101, '2020-08-18', 21, 525, 0),
('1012', 33, 101, '2020-08-18', 40, 1000, 0),
('10120', 7, 101, '2020-08-18', 19, 475, 0),
('10121', 26, 101, '2020-08-18', 14, 350, 0),
('10122', 68, 101, '2020-08-18', 36, 900, 0),
('10123', 32, 101, '2020-08-18', 20, 500, 0),
('10124', 64, 101, '2020-08-18', 12, 300, 0),
('10125', 9, 101, '2020-08-18', 15, 375, 0),
('10126', 15, 101, '2020-08-18', 23, 575, 0),
('10127', 4, 101, '2020-08-18', 13, 325, 0),
('10128', 27, 101, '2020-08-18', 11, 275, 0),
('1013', 1, 101, '2020-08-18', 62, 1550, 0),
('1014', 30, 101, '2020-08-18', 49, 1225, 0),
('1015', 29, 101, '2020-08-18', 56, 1400, 0),
('1016', 17, 101, '2020-08-18', 72, 1800, 0),
('1017', 16, 101, '2020-08-18', 19, 475, 0),
('1018', 54, 101, '2020-08-18', 51, 1275, 0),
('1019', 34, 101, '2020-08-18', 31, 775, 0),
('1021', 1, 102, '2020-08-19', 46, 1150, 0),
('10210', 21, 102, '2020-08-19', 30, 750, 0),
('10211', 54, 102, '2020-08-19', 38, 950, 0),
('10212', 34, 102, '2020-08-19', 37, 925, 0),
('10213', 46, 102, '2020-08-19', 4, 100, 0),
('10214', 29, 102, '2020-08-19', 57, 1425, 0),
('10215', 30, 102, '2020-08-19', 57, 1425, 0),
('10216', 63, 102, '2020-08-19', 15, 375, 0),
('10217', 32, 102, '2020-08-19', 6, 150, 0),
('10218', 3, 102, '2020-08-19', 52, 1300, 0),
('10219', 13, 102, '2020-08-19', 51, 1275, 0),
('1022', 2, 102, '2020-08-19', 70, 1750, 0),
('10220', 26, 102, '2020-08-19', 24, 600, 0),
('10221', 64, 102, '2020-08-19', 18, 450, 0),
('10222', 16, 102, '2020-08-19', 34, 850, 0),
('10223', 9, 102, '2020-08-19', 24, 600, 0),
('10224', 22, 102, '2020-08-19', 25, 625, 0),
('10225', 20, 102, '2020-08-19', 11, 275, 0),
('10226', 72, 102, '2020-08-19', 28, 700, 0),
('10227', 81, 102, '2020-08-19', 3, 75, 0),
('10228', 69, 102, '2020-08-19', 16, 400, 0),
('10229', 15, 102, '2020-08-19', 35, 875, 0),
('1023', 33, 102, '2020-08-19', 55, 1375, 0),
('10230', 18, 102, '2020-08-19', 11, 275, 0),
('10231', 41, 102, '2020-08-19', 3, 75, 0),
('1024', 4, 102, '2020-08-19', 46, 1150, 0),
('1025', 7, 102, '2020-08-19', 16, 400, 0),
('1026', 83, 102, '2020-08-19', 24, 600, 0),
('1027', 68, 102, '2020-08-19', 30, 750, 0),
('1028', 19, 102, '2020-08-19', 57, 1425, 0),
('1029', 24, 102, '2020-08-19', 20, 500, 0),
('1031', 2, 103, '2020-08-20', 72, 1800, 0),
('10310', 8, 103, '2020-08-20', 20, 500, 0),
('10311', 16, 103, '2020-08-20', 39, 975, 0),
('10312', 17, 103, '2020-08-20', 24, 600, 0),
('10313', 9, 103, '2020-08-20', 19, 475, 0),
('10314', 7, 103, '2020-08-20', 25, 625, 0),
('10315', 29, 103, '2020-08-20', 52, 1300, 0),
('10316', 30, 103, '2020-08-20', 50, 1250, 0),
('10317', 21, 103, '2020-08-20', 23, 575, 0),
('10318', 54, 103, '2020-08-20', 29, 725, 0),
('10319', 22, 103, '2020-08-20', 18, 450, 0),
('1032', 3, 103, '2020-08-20', 69, 1725, 0),
('10320', 32, 103, '2020-08-20', 26, 650, 0),
('10321', 72, 103, '2020-08-20', 30, 750, 0),
('10322', 31, 103, '2020-08-20', 34, 850, 0),
('10323', 27, 103, '2020-08-20', 14, 350, 0),
('10324', 20, 103, '2020-08-20', 18, 450, 0),
('10325', 24, 103, '2020-08-20', 17, 425, 0),
('10326', 69, 103, '2020-08-20', 14, 350, 0),
('10327', 26, 103, '2020-08-20', 16, 400, 0),
('1033', 1, 103, '2020-08-20', 68, 1700, 0),
('1034', 15, 103, '2020-08-20', 33, 825, 0),
('1035', 34, 103, '2020-08-20', 37, 925, 0),
('1036', 4, 103, '2020-08-20', 55, 1375, 0),
('1037', 64, 103, '2020-08-20', 14, 350, 0),
('1038', 13, 103, '2020-08-20', 50, 1250, 0),
('1039', 19, 103, '2020-08-20', 115, 2875, 0),
('1041', 2, 104, '2020-08-21', 51, 1275, 0),
('10410', 4, 104, '2020-08-21', 36, 900, 0),
('10411', 64, 104, '2020-08-21', 14, 350, 0),
('10412', 26, 104, '2020-08-21', 22, 550, 0),
('10413', 32, 104, '2020-08-21', 20, 500, 0),
('10414', 31, 104, '2020-08-21', 34, 850, 0),
('10415', 3, 104, '2020-08-21', 44, 1100, 0),
('10416', 30, 104, '2020-08-21', 38, 950, 0),
('10417', 29, 104, '2020-08-21', 39, 975, 0),
('10418', 16, 104, '2020-08-21', 26, 650, 0),
('10419', 8, 104, '2020-08-21', 17, 425, 0),
('1042', 1, 104, '2020-08-21', 50, 1250, 0),
('10420', 21, 104, '2020-08-21', 21, 525, 0),
('10421', 20, 104, '2020-08-21', 19, 475, 0),
('10422', 9, 104, '2020-08-21', 14, 350, 0),
('10423', 22, 104, '2020-08-21', 16, 400, 0),
('10424', 72, 104, '2020-08-21', 28, 700, 0),
('10425', 69, 104, '2020-08-21', 14, 350, 0),
('10426', 83, 104, '2020-08-21', 15, 375, 0),
('10427', 27, 104, '2020-08-21', 6, 150, 0),
('10428', 18, 104, '2020-08-21', 16, 400, 0),
('10429', 24, 104, '2020-08-21', 17, 425, 0),
('1043', 33, 104, '2020-08-21', 43, 1075, 0),
('10430', 7, 104, '2020-08-21', 13, 325, 0),
('10431', 15, 104, '2020-08-21', 6, 150, 0),
('1044', 19, 104, '2020-08-21', 86, 2150, 0),
('1045', 54, 104, '2020-08-21', 96, 2400, 0),
('1046', 34, 104, '2020-08-21', 48, 1200, 0),
('1047', 13, 104, '2020-08-21', 41, 1025, 0),
('1048', 68, 104, '2020-08-21', 48, 1200, 0),
('1049', 17, 104, '2020-08-21', 50, 1250, 0),
('1051', 1, 105, '2020-08-24', 59, 1475, 0),
('10510', 54, 105, '2020-08-24', 73, 1825, 0),
('10511', 34, 105, '2020-08-24', 49, 1225, 0),
('10512', 46, 105, '2020-08-24', 8, 200, 0),
('10513', 29, 105, '2020-08-24', 47, 1175, 0),
('10514', 30, 105, '2020-08-24', 47, 1175, 0),
('10515', 31, 105, '2020-08-24', 36, 900, 0),
('10516', 32, 105, '2020-08-24', 24, 600, 0),
('10517', 3, 105, '2020-08-24', 45, 1125, 0),
('10518', 13, 105, '2020-08-24', 38, 950, 0),
('10519', 26, 105, '2020-08-24', 22, 550, 0),
('1052', 2, 105, '2020-08-24', 64, 1600, 0),
('10520', 64, 105, '2020-08-24', 13, 325, 0),
('10521', 9, 105, '2020-08-24', 20, 500, 0),
('10522', 22, 105, '2020-08-24', 20, 500, 0),
('10523', 20, 105, '2020-08-24', 21, 525, 0),
('10524', 72, 105, '2020-08-24', 31, 775, 0),
('10525', 69, 105, '2020-08-24', 7, 175, 0),
('10526', 17, 105, '2020-08-24', 60, 1500, 0),
('10527', 18, 105, '2020-08-24', 5, 125, 0),
('10528', 27, 105, '2020-08-24', 16, 400, 0),
('10529', 41, 105, '2020-08-24', 4, 100, 0),
('1053', 33, 105, '2020-08-24', 42, 1050, 0),
('10530', 16, 105, '2020-08-24', 16, 400, 0),
('1054', 4, 105, '2020-08-24', 32, 800, 0),
('1055', 7, 105, '2020-08-24', 17, 425, 0),
('1056', 68, 105, '2020-08-24', 43, 1075, 0),
('1057', 19, 105, '2020-08-24', 92, 2300, 0),
('1058', 24, 105, '2020-08-24', 17, 425, 0),
('1059', 21, 105, '2020-08-24', 23, 575, 0),
('1061', 1, 106, '2020-08-31', 52, 1300, 0),
('10610', 30, 106, '2020-08-31', 48, 1200, 0),
('10611', 29, 106, '2020-08-31', 50, 1250, 0),
('10612', 3, 106, '2020-08-31', 46, 1150, 0),
('10613', 31, 106, '2020-08-31', 37, 925, 0),
('10614', 17, 106, '2020-08-31', 41, 1025, 0),
('10615', 32, 106, '2020-08-31', 24, 600, 0),
('10616', 83, 106, '2020-08-31', 22, 550, 0),
('10617', 22, 106, '2020-08-31', 15, 375, 0),
('10618', 35, 106, '2020-08-31', 3, 75, 0),
('10619', 21, 106, '2020-08-31', 25, 625, 0),
('1062', 2, 106, '2020-08-31', 54, 1350, 0),
('10620', 19, 106, '2020-08-31', 34, 850, 0),
('10621', 20, 106, '2020-08-31', 21, 525, 0),
('10622', 24, 106, '2020-08-31', 13, 325, 0),
('10623', 16, 106, '2020-08-31', 11, 275, 0),
('10624', 4, 106, '2020-08-31', 24, 600, 0),
('10625', 9, 106, '2020-08-31', 16, 400, 0),
('10626', 64, 106, '2020-08-31', 22, 550, 0),
('10627', 8, 106, '2020-08-31', 8, 200, 0),
('10628', 46, 106, '2020-08-31', 6, 150, 0),
('10629', 69, 106, '2020-08-31', 17, 425, 0),
('1063', 68, 106, '2020-08-31', 32, 800, 0),
('10630', 72, 106, '2020-08-31', 27, 675, 0),
('10631', 84, 106, '2020-08-31', 5, 125, 0),
('10632', 7, 106, '2020-08-31', 8, 200, 0),
('10633', 27, 106, '2020-08-31', 9, 225, 0),
('1064', 54, 106, '2020-08-31', 91, 2275, 0),
('1065', 34, 106, '2020-08-31', 46, 1150, 0),
('1066', 13, 106, '2020-08-31', 40, 1000, 0),
('1067', 26, 106, '2020-08-31', 23, 575, 0),
('1068', 18, 106, '2020-08-31', 60, 1500, 0),
('1069', 33, 106, '2020-08-31', 43, 1075, 0),
('1071', 1, 107, '2020-09-07', 53, 1325, 0),
('10710', 18, 107, '2020-09-07', 58, 1450, 0),
('10711', 30, 107, '2020-09-07', 48, 1200, 0),
('10712', 29, 107, '2020-09-07', 46, 1150, 0),
('10713', 64, 107, '2020-09-07', 18, 450, 0),
('10714', 9, 107, '2020-09-07', 19, 475, 0),
('10715', 32, 107, '2020-09-07', 24, 600, 0),
('10716', 72, 107, '2020-09-07', 28, 700, 0),
('10717', 3, 107, '2020-09-07', 45, 1125, 0),
('10718', 69, 107, '2020-09-07', 15, 375, 0),
('10719', 27, 107, '2020-09-07', 8, 200, 0),
('1072', 2, 107, '2020-09-07', 54, 1350, 0),
('10720', 31, 107, '2020-09-07', 34, 850, 0),
('10721', 22, 107, '2020-09-07', 19, 475, 0),
('10722', 21, 107, '2020-09-07', 24, 600, 0),
('10723', 7, 107, '2020-09-07', 16, 400, 0),
('10724', 24, 107, '2020-09-07', 18, 450, 0),
('10725', 19, 107, '2020-09-07', 34, 850, 0),
('10726', 46, 107, '2020-09-07', 16, 400, 0),
('10727', 83, 107, '2020-09-07', 8, 200, 0),
('10728', 16, 107, '2020-09-07', 11, 275, 0),
('10729', 4, 107, '2020-09-07', 20, 500, 0),
('1073', 17, 107, '2020-09-07', 59, 1475, 0),
('10730', 84, 107, '2020-09-07', 4, 100, 0),
('10731', 20, 107, '2020-09-07', 11, 275, 0),
('10732', 35, 107, '2020-09-07', 5, 125, 0),
('10733', 41, 107, '2020-09-07', 6, 150, 0),
('1074', 54, 107, '2020-09-07', 91, 2275, 0),
('1075', 26, 107, '2020-09-07', 21, 525, 0),
('1076', 34, 107, '2020-09-07', 45, 1125, 0),
('1077', 35, 107, '2020-09-07', 30, 750, 0),
('1078', 13, 107, '2020-09-07', 40, 1000, 0),
('1079', 33, 107, '2020-09-07', 38, 950, 0),
('1081', 34, 108, '2020-09-12', 50, 1250, 0),
('10810', 2, 108, '2020-09-12', 60, 1500, 0),
('10811', 32, 108, '2020-09-12', 28, 700, 0),
('10812', 18, 108, '2020-09-12', 55, 1375, 0),
('10813', 3, 108, '2020-09-12', 40, 1000, 0),
('10814', 29, 108, '2020-09-12', 48, 1200, 0),
('10815', 30, 108, '2020-09-12', 48, 1200, 0),
('10816', 33, 108, '2020-09-12', 40, 1000, 0),
('10817', 31, 108, '2020-09-12', 36, 900, 0),
('10818', 69, 108, '2020-09-12', 20, 500, 0),
('10819', 22, 108, '2020-09-12', 21, 525, 0),
('1082', 26, 108, '2020-09-12', 25, 625, 0),
('10820', 72, 108, '2020-09-12', 33, 825, 0),
('10821', 9, 108, '2020-09-12', 17, 425, 0),
('10822', 83, 108, '2020-09-12', 10, 250, 0),
('10823', 4, 108, '2020-09-12', 18, 450, 0),
('10824', 24, 108, '2020-09-12', 19, 475, 0),
('10825', 19, 108, '2020-09-12', 27, 675, 0),
('10826', 64, 108, '2020-09-12', 12, 300, 0),
('10827', 21, 108, '2020-09-12', 20, 500, 0),
('10828', 22, 108, '2020-09-12', 7, 175, 0),
('10829', 27, 108, '2020-09-12', 18, 450, 0),
('1083', 54, 108, '2020-09-12', 113, 2825, 0),
('10830', 46, 108, '2020-09-12', 8, 200, 0),
('10831', 7, 108, '2020-09-12', 15, 375, 0),
('1084', 17, 108, '2020-09-12', 63, 1575, 0),
('1085', 13, 108, '2020-09-12', 42, 1050, 0),
('1086', 1, 108, '2020-09-12', 56, 1400, 0),
('1087', 35, 108, '2020-09-12', 24, 600, 0),
('1088', 16, 108, '2020-09-12', 27, 675, 0),
('1089', 85, 108, '2020-09-12', 22, 550, 0),
('1091', 18, 109, '2020-09-14', 59, 1475, 0),
('10910', 19, 109, '2020-09-14', 59, 1475, 0),
('10911', 31, 109, '2020-09-14', 38, 950, 0),
('10912', 3, 109, '2020-09-14', 42, 1050, 0),
('10913', 33, 109, '2020-09-14', 41, 1025, 0),
('10914', 32, 109, '2020-09-14', 26, 650, 0),
('10915', 16, 109, '2020-09-14', 28, 700, 0),
('10916', 83, 109, '2020-09-14', 16, 400, 0),
('10917', 21, 109, '2020-09-14', 26, 650, 0),
('10918', 22, 109, '2020-09-14', 22, 550, 0),
('10919', 46, 109, '2020-09-14', 22, 550, 0),
('1092', 17, 109, '2020-09-14', 59, 1475, 0),
('10920', 4, 109, '2020-09-14', 20, 500, 0),
('10921', 9, 109, '2020-09-14', 15, 375, 0),
('10922', 24, 109, '2020-09-14', 21, 525, 0),
('10923', 64, 109, '2020-09-14', 17, 425, 0),
('10924', 7, 109, '2020-09-14', 18, 450, 0),
('10925', 72, 109, '2020-09-14', 28, 700, 0),
('10926', 69, 109, '2020-09-14', 19, 475, 0),
('10927', 30, 109, '2020-09-14', 48, 1200, 0),
('10928', 35, 109, '2020-09-14', 6, 150, 0),
('10929', 29, 109, '2020-09-14', 26, 650, 0),
('1093', 13, 109, '2020-09-14', 42, 1050, 0),
('10930', 34, 109, '2020-09-14', 18, 450, 0),
('10931', 27, 109, '2020-09-14', 11, 275, 0),
('1094', 54, 109, '2020-09-14', 92, 2300, 0),
('1095', 26, 109, '2020-09-14', 24, 600, 0),
('1096', 2, 109, '2020-09-14', 64, 1600, 0),
('1097', 35, 109, '2020-09-14', 30, 750, 0),
('1098', 1, 109, '2020-09-14', 63, 1575, 0),
('1099', 35, 109, '2020-09-14', 16, 400, 0),
('1101', 34, 110, '2020-09-21', 43, 1075, 0),
('11010', 33, 110, '2020-09-21', 43, 1075, 0),
('11011', 29, 110, '2020-09-21', 45, 1125, 0),
('11012', 30, 110, '2020-09-21', 44, 1100, 0),
('11013', 32, 110, '2020-09-21', 23, 575, 0),
('11014', 31, 110, '2020-09-21', 31, 775, 0),
('11015', 4, 110, '2020-09-21', 17, 425, 0),
('11016', 3, 110, '2020-09-21', 44, 1100, 0),
('11017', 16, 110, '2020-09-21', 12, 300, 0),
('11018', 83, 110, '2020-09-21', 9, 225, 0),
('11019', 46, 110, '2020-09-21', 14, 350, 0),
('1102', 18, 110, '2020-09-21', 59, 1475, 0),
('11020', 9, 110, '2020-09-21', 17, 425, 0),
('11021', 21, 110, '2020-09-21', 24, 600, 0),
('11022', 22, 110, '2020-09-21', 21, 525, 0),
('11023', 20, 110, '2020-09-21', 25, 625, 0),
('11024', 24, 110, '2020-09-21', 19, 475, 0),
('11025', 64, 110, '2020-09-21', 18, 450, 0),
('11026', 7, 110, '2020-09-21', 17, 425, 0),
('11027', 69, 110, '2020-09-21', 16, 400, 0),
('11028', 35, 110, '2020-09-21', 15, 375, 0),
('11029', 19, 110, '2020-09-21', 42, 1050, 0),
('1103', 17, 110, '2020-09-21', 61, 1525, 0),
('11030', 72, 110, '2020-09-21', 27, 675, 0),
('11031', 10, 110, '2020-09-21', 7, 175, 0),
('11032', 27, 110, '2020-09-21', 11, 275, 0),
('1104', 2, 110, '2020-09-21', 61, 1525, 0),
('1105', 1, 110, '2020-09-21', 53, 1325, 0),
('1106', 13, 110, '2020-09-21', 43, 1075, 0),
('1107', 54, 110, '2020-09-21', 77, 1925, 0),
('1108', 26, 110, '2020-09-21', 24, 600, 0),
('1109', 35, 110, '2020-09-21', 22, 550, 0),
('1111', 34, 111, '2020-09-28', 48, 1200, 0),
('11110', 3, 111, '2020-09-28', 48, 1200, 0),
('11111', 29, 111, '2020-09-28', 51, 1275, 0),
('11112', 30, 111, '2020-09-28', 51, 1275, 0),
('11113', 31, 111, '2020-09-28', 35, 875, 0),
('11114', 16, 111, '2020-09-28', 32, 800, 0),
('11115', 46, 111, '2020-09-28', 20, 500, 0),
('11116', 32, 111, '2020-09-28', 20, 500, 0),
('11117', 64, 111, '2020-09-28', 20, 500, 0),
('11118', 35, 111, '2020-09-28', 29, 725, 0),
('11119', 21, 111, '2020-09-28', 28, 700, 0),
('1112', 18, 111, '2020-09-28', 82, 2050, 0),
('11120', 22, 111, '2020-09-28', 20, 500, 0),
('11121', 20, 111, '2020-09-28', 19, 475, 0),
('11122', 24, 111, '2020-09-28', 22, 550, 0),
('11123', 4, 111, '2020-09-28', 15, 375, 0),
('11124', 68, 111, '2020-09-28', 16, 400, 0),
('11125', 69, 111, '2020-09-28', 8, 200, 0),
('11126', 7, 111, '2020-09-28', 18, 450, 0),
('11127', 72, 111, '2020-09-28', 27, 675, 0),
('11128', 84, 111, '2020-09-28', 10, 250, 0),
('11129', 10, 111, '2020-09-28', 9, 225, 0),
('1113', 1, 111, '2020-09-28', 58, 1450, 0),
('11130', 27, 111, '2020-09-28', 22, 550, 0),
('11131', 9, 111, '2020-09-28', 13, 325, 0),
('1114', 2, 111, '2020-09-28', 63, 1575, 0),
('1115', 17, 111, '2020-09-28', 35, 875, 0),
('1116', 13, 111, '2020-09-28', 44, 1100, 0),
('1117', 54, 111, '2020-09-28', 49, 1225, 0),
('1118', 33, 111, '2020-09-28', 46, 1150, 0),
('1119', 19, 111, '2020-09-28', 37, 925, 0),
('1121', 34, 112, '2020-10-05', 40, 1000, 0),
('11210', 18, 112, '2020-10-05', 65, 1625, 0),
('11211', 33, 112, '2020-10-05', 45, 1125, 0),
('11212', 3, 112, '2020-10-05', 47, 1175, 0),
('11213', 30, 112, '2020-10-05', 50, 1250, 0),
('11214', 29, 112, '2020-10-05', 50, 1250, 0),
('11215', 31, 112, '2020-10-05', 30, 750, 0),
('11216', 27, 112, '2020-10-05', 3, 75, 0),
('11217', 83, 112, '2020-10-05', 26, 650, 0),
('11218', 20, 112, '2020-10-05', 22, 550, 0),
('11219', 22, 112, '2020-10-05', 18, 450, 0),
('1122', 26, 112, '2020-10-05', 5, 125, 0),
('11220', 72, 112, '2020-10-05', 20, 500, 0),
('11221', 4, 112, '2020-10-05', 23, 575, 0),
('11222', 7, 112, '2020-10-05', 15, 375, 0),
('11223', 64, 112, '2020-10-05', 11, 275, 0),
('11224', 24, 112, '2020-10-05', 23, 575, 0),
('11225', 21, 112, '2020-10-05', 26, 650, 0),
('11226', 50, 112, '2020-10-05', 12, 300, 0),
('11227', 19, 112, '2020-10-05', 56, 1400, 0),
('11228', 9, 112, '2020-10-05', 16, 400, 0),
('11229', 69, 112, '2020-10-05', 3, 75, 0),
('1123', 54, 112, '2020-10-05', 33, 825, 0),
('11230', 10, 112, '2020-10-05', 8, 200, 0),
('11231', 86, 112, '2020-10-05', 5, 125, 0),
('11232', 16, 112, '2020-10-05', 22, 550, 0),
('1124', 13, 112, '2020-10-05', 62, 1550, 0),
('1125', 17, 112, '2020-10-05', 60, 1500, 0),
('1126', 35, 112, '2020-10-05', 37, 925, 0),
('1127', 32, 112, '2020-10-05', 48, 1200, 0),
('1128', 1, 112, '2020-10-05', 64, 1600, 0),
('1129', 2, 112, '2020-10-05', 72, 1800, 0),
('1131', 4, 113, '2020-09-12', 36, 900, 0),
('11310', 29, 113, '2020-09-12', 64, 1600, 0),
('11311', 30, 113, '2020-09-12', 50, 1250, 0),
('11312', 13, 113, '2020-09-12', 45, 1125, 0),
('11313', 32, 113, '2020-09-12', 26, 650, 0),
('11314', 31, 113, '2020-09-12', 42, 1050, 0),
('11315', 19, 113, '2020-09-12', 38, 950, 0),
('11316', 83, 113, '2020-09-12', 16, 400, 0),
('11317', 9, 113, '2020-09-12', 15, 375, 0),
('11318', 35, 113, '2020-09-12', 28, 700, 0),
('11319', 64, 113, '2020-09-12', 8, 200, 0),
('1132', 1, 113, '2020-09-12', 60, 1500, 0),
('11320', 72, 113, '2020-09-12', 28, 700, 0),
('11321', 27, 113, '2020-09-12', 15, 375, 0),
('11322', 7, 113, '2020-09-12', 15, 375, 0),
('11323', 50, 113, '2020-09-12', 17, 425, 0),
('11324', 10, 113, '2020-09-12', 7, 175, 0),
('11325', 20, 113, '2020-09-12', 21, 525, 0),
('11326', 22, 113, '2020-09-12', 19, 475, 0),
('11327', 21, 113, '2020-09-12', 21, 525, 0),
('11328', 24, 113, '2020-09-12', 7, 175, 0),
('1133', 2, 113, '2020-09-12', 65, 1625, 0),
('1134', 17, 113, '2020-09-12', 20, 500, 0),
('1135', 34, 113, '2020-09-12', 46, 1150, 0),
('1136', 54, 113, '2020-09-12', 51, 1275, 0),
('1137', 33, 113, '2020-09-12', 12, 300, 0),
('1138', 3, 113, '2020-09-12', 52, 1300, 0),
('1139', 18, 113, '2020-09-12', 66, 1650, 0),
('1141', 2, 114, '2020-10-07', 50, 1250, 0),
('11410', 26, 114, '2020-10-07', 23, 575, 0),
('11411', 30, 114, '2020-10-07', 49, 1225, 0),
('11412', 35, 114, '2020-10-07', 27, 675, 0),
('11413', 31, 114, '2020-10-07', 35, 875, 0),
('11414', 32, 114, '2020-10-07', 25, 625, 0),
('11415', 72, 114, '2020-10-07', 30, 750, 0),
('11416', 33, 114, '2020-10-07', 23, 575, 0),
('11417', 4, 114, '2020-10-07', 21, 525, 0),
('11418', 18, 114, '2020-10-07', 57, 1425, 0),
('11419', 3, 114, '2020-10-07', 37, 925, 0),
('1142', 1, 114, '2020-10-07', 44, 1100, 0),
('11420', 7, 114, '2020-10-07', 19, 475, 0),
('11421', 21, 114, '2020-10-07', 26, 650, 0),
('11422', 22, 114, '2020-10-07', 25, 625, 0),
('11423', 9, 114, '2020-10-07', 17, 425, 0),
('11424', 16, 114, '2020-10-07', 13, 325, 0),
('11425', 50, 114, '2020-10-07', 19, 475, 0),
('11426', 83, 114, '2020-10-07', 7, 175, 0),
('11427', 20, 114, '2020-10-07', 28, 700, 0),
('11428', 24, 114, '2020-10-07', 22, 550, 0),
('11429', 84, 114, '2020-10-07', 14, 350, 0),
('1143', 17, 114, '2020-10-07', 62, 1550, 0),
('11430', 46, 114, '2020-10-07', 10, 250, 0),
('11431', 10, 114, '2020-10-07', 10, 250, 0),
('11432', 69, 114, '2020-10-07', 9, 225, 0),
('11433', 27, 114, '2020-10-07', 11, 275, 0),
('1144', 13, 114, '2020-10-07', 40, 1000, 0),
('1145', 34, 114, '2020-10-07', 32, 800, 0),
('1146', 6, 114, '2020-10-07', 12, 300, 0),
('1147', 54, 114, '2020-10-07', 76, 1900, 0),
('1148', 29, 114, '2020-10-07', 52, 1300, 0),
('1149', 19, 114, '2020-10-07', 30, 750, 0),
('1151', 1, 115, '2020-10-15', 56, 1400, 0),
('11510', 54, 115, '2020-10-15', 81, 2025, 0),
('11511', 34, 115, '2020-10-15', 34, 850, 0),
('11512', 46, 115, '2020-10-15', 14, 350, 0),
('11513', 7, 115, '2020-10-15', 22, 550, 0),
('11514', 21, 115, '2020-10-15', 24, 600, 0),
('11515', 24, 115, '2020-10-15', 15, 375, 0),
('11516', 22, 115, '2020-10-15', 28, 700, 0),
('11517', 20, 115, '2020-10-15', 32, 800, 0),
('11518', 3, 115, '2020-10-15', 46, 1150, 0),
('11519', 50, 115, '2020-10-15', 20, 500, 0),
('1152', 13, 115, '2020-10-15', 44, 1100, 0),
('11520', 72, 115, '2020-10-15', 39, 975, 0),
('11521', 27, 115, '2020-10-15', 23, 575, 0),
('11522', 33, 115, '2020-10-15', 42, 1050, 0),
('11523', 9, 115, '2020-10-15', 18, 450, 0),
('11524', 32, 115, '2020-10-15', 15, 375, 0),
('11525', 31, 115, '2020-10-15', 36, 900, 0),
('11526', 4, 115, '2020-10-15', 16, 400, 0),
('11527', 29, 115, '2020-10-15', 52, 1300, 0),
('11528', 38, 115, '2020-10-15', 18, 450, 0),
('11529', 30, 115, '2020-10-15', 51, 1275, 0),
('1153', 17, 115, '2020-10-15', 45, 1125, 0),
('11530', 68, 115, '2020-10-15', 21, 525, 0),
('11531', 10, 115, '2020-10-15', 7, 175, 0),
('1154', 16, 115, '2020-10-15', 31, 775, 0),
('1155', 2, 115, '2020-10-15', 60, 1500, 0),
('1156', 19, 115, '2020-10-15', 35, 875, 0),
('1157', 18, 115, '2020-10-15', 54, 1350, 0),
('1158', 15, 115, '2020-10-15', 20, 500, 0),
('1159', 6, 115, '2020-10-15', 27, 675, 0),
('1161', 2, 116, '0000-00-00', 61, 1525, 0),
('11610', 13, 116, '0000-00-00', 46, 1150, 0),
('11611', 17, 116, '0000-00-00', 52, 1300, 0),
('11612', 15, 116, '0000-00-00', 26, 650, 0),
('11613', 18, 116, '0000-00-00', 54, 1350, 0),
('11614', 3, 116, '0000-00-00', 40, 1000, 0),
('11615', 31, 116, '0000-00-00', 30, 750, 0),
('11616', 20, 116, '0000-00-00', 23, 575, 0),
('11617', 21, 116, '0000-00-00', 23, 575, 0),
('11618', 6, 116, '0000-00-00', 31, 775, 0),
('11619', 32, 116, '0000-00-00', 20, 500, 0),
('1162', 30, 116, '0000-00-00', 57, 1425, 0),
('11620', 24, 116, '0000-00-00', 17, 425, 0),
('11621', 68, 116, '0000-00-00', 14, 350, 0),
('11622', 22, 116, '0000-00-00', 21, 525, 0),
('11623', 9, 116, '0000-00-00', 16, 400, 0),
('11624', 72, 116, '0000-00-00', 34, 850, 0),
('11625', 46, 116, '0000-00-00', 16, 400, 0),
('11626', 50, 116, '0000-00-00', 18, 450, 0),
('11627', 10, 116, '0000-00-00', 7, 175, 0),
('11628', 33, 116, '0000-00-00', 24, 600, 0),
('11629', 27, 116, '0000-00-00', 6, 150, 0),
('1163', 34, 116, '0000-00-00', 41, 1025, 0),
('11630', 7, 116, '0000-00-00', 3, 75, 0),
('11631', 84, 116, '0000-00-00', 5, 125, 0),
('11632', 69, 116, '0000-00-00', 5, 125, 0),
('11633', 5, 116, '0000-00-00', 19, 475, 0),
('1164', 19, 116, '0000-00-00', 45, 1125, 0),
('1165', 26, 116, '0000-00-00', 28, 700, 0),
('1166', 29, 116, '0000-00-00', 58, 1450, 0),
('1167', 4, 116, '0000-00-00', 26, 650, 0),
('1168', 1, 116, '0000-00-00', 58, 1450, 0),
('1169', 54, 116, '0000-00-00', 89, 2225, 0),
('1171', 1, 117, '0000-00-00', 55, 1375, 0),
('11710', 18, 117, '0000-00-00', 57, 1425, 0),
('11711', 32, 117, '0000-00-00', 24, 600, 0),
('11712', 84, 117, '0000-00-00', 13, 325, 0),
('11713', 15, 117, '0000-00-00', 27, 675, 0),
('11714', 29, 117, '0000-00-00', 51, 1275, 0),
('11715', 33, 117, '0000-00-00', 38, 950, 0),
('11716', 30, 117, '0000-00-00', 48, 1200, 0),
('11717', 68, 117, '0000-00-00', 23, 575, 0),
('11718', 20, 117, '0000-00-00', 21, 525, 0),
('11719', 31, 117, '0000-00-00', 28, 700, 0),
('1172', 2, 117, '0000-00-00', 41, 1025, 0),
('11720', 21, 117, '0000-00-00', 20, 500, 0),
('11721', 3, 117, '0000-00-00', 44, 1100, 0),
('11722', 46, 117, '0000-00-00', 21, 525, 0),
('11723', 24, 117, '0000-00-00', 17, 425, 0),
('11724', 22, 117, '0000-00-00', 20, 500, 0),
('11725', 7, 117, '0000-00-00', 17, 425, 0),
('11726', 4, 117, '0000-00-00', 23, 575, 0),
('11727', 9, 117, '0000-00-00', 16, 400, 0),
('11728', 10, 117, '0000-00-00', 8, 200, 0),
('11729', 72, 117, '0000-00-00', 27, 675, 0),
('1173', 54, 117, '0000-00-00', 86, 2150, 0),
('11730', 14, 117, '0000-00-00', 1, 25, 0),
('11731', 5, 117, '0000-00-00', 14, 350, 0),
('11732', 50, 117, '0000-00-00', 14, 350, 0),
('1174', 5, 117, '0000-00-00', 34, 850, 0),
('1175', 34, 117, '0000-00-00', 52, 1300, 0),
('1176', 17, 117, '0000-00-00', 47, 1175, 0),
('1177', 13, 117, '0000-00-00', 30, 750, 0),
('1178', 19, 117, '0000-00-00', 22, 550, 0),
('1179', 26, 117, '0000-00-00', 28, 700, 0),
('1181', 2, 118, '2020-11-03', 21, 525, 0),
('11810', 33, 118, '2020-11-03', 16, 400, 0),
('11811', 31, 118, '2020-11-03', 15, 375, 0),
('11812', 18, 118, '2020-11-03', 22, 550, 0),
('11813', 21, 118, '2020-11-03', 11, 275, 0),
('11814', 20, 118, '2020-11-03', 10, 250, 0),
('11815', 22, 118, '2020-11-03', 10, 250, 0),
('11816', 4, 118, '2020-11-03', 7, 175, 0),
('11817', 41, 118, '2020-11-03', 4, 100, 0),
('11818', 24, 118, '2020-11-03', 9, 225, 0),
('11819', 46, 118, '2020-11-03', 7, 175, 0),
('1182', 1, 118, '2020-11-03', 20, 500, 0),
('11820', 19, 118, '2020-11-03', 12, 300, 0),
('11821', 50, 118, '2020-11-03', 7, 175, 0),
('11822', 9, 118, '2020-11-03', 8, 200, 0),
('11823', 7, 118, '2020-11-03', 8, 200, 0),
('11824', 72, 118, '2020-11-03', 11, 275, 0),
('11825', 16, 118, '2020-11-03', 6, 150, 0),
('11826', 5, 118, '2020-11-03', 8, 200, 0),
('11827', 2, 118, '2020-11-04', 24, 600, 0),
('11828', 1, 118, '2020-11-04', 24, 600, 0),
('11829', 34, 118, '2020-11-04', 20, 500, 0),
('1183', 54, 118, '2020-11-03', 21, 525, 0),
('11830', 17, 118, '2020-11-04', 25, 625, 0),
('11831', 15, 118, '2020-11-04', 10, 250, 0),
('11832', 32, 118, '2020-11-04', 12, 300, 0),
('11833', 13, 118, '2020-11-04', 21, 525, 0),
('11834', 3, 118, '2020-11-04', 24, 600, 0),
('11835', 33, 118, '2020-11-04', 16, 400, 0),
('11836', 31, 118, '2020-11-04', 17, 425, 0),
('11837', 18, 118, '2020-11-04', 28, 700, 0),
('11838', 21, 118, '2020-11-04', 15, 375, 0),
('11839', 22, 118, '2020-11-04', 13, 325, 0),
('1184', 34, 118, '2020-11-03', 20, 500, 0),
('11840', 24, 118, '2020-11-04', 10, 250, 0),
('11841', 46, 118, '2020-11-04', 4, 100, 0),
('11842', 19, 118, '2020-11-04', 16, 400, 0),
('11843', 9, 118, '2020-11-04', 9, 225, 0),
('11844', 7, 118, '2020-11-04', 9, 225, 0),
('11845', 72, 118, '2020-11-04', 17, 425, 0),
('11846', 26, 118, '2020-11-04', 12, 300, 0),
('11847', 68, 118, '2020-11-04', 13, 325, 0),
('11848', 4, 118, '2020-11-04', 8, 200, 0),
('11849', 82, 118, '2020-11-04', 0, 0, 0),
('1185', 17, 118, '2020-11-03', 20, 500, 0),
('11850', 50, 118, '2020-11-04', 8, 200, 0),
('11851', 10, 118, '2020-11-04', 4, 100, 0),
('11852', 2, 118, '2020-11-05', 19, 475, 0),
('11853', 1, 118, '2020-11-05', 17, 425, 0),
('11854', 54, 118, '2020-11-05', 14, 350, 0),
('11855', 34, 118, '2020-11-05', 17, 425, 0),
('11856', 15, 118, '2020-11-05', 8, 200, 0),
('11857', 32, 118, '2020-11-05', 11, 275, 0),
('11858', 13, 118, '2020-11-05', 13, 325, 0),
('11859', 3, 118, '2020-11-05', 17, 425, 0),
('1186', 15, 118, '2020-11-03', 10, 250, 0),
('11860', 33, 118, '2020-11-05', 11, 275, 0),
('11861', 31, 118, '2020-11-05', 9, 225, 0),
('11862', 18, 118, '2020-11-05', 20, 500, 0),
('11863', 21, 118, '2020-11-05', 7, 175, 0),
('11864', 4, 118, '2020-11-05', 5, 125, 0),
('11865', 22, 118, '2020-11-05', 8, 200, 0),
('11866', 24, 118, '2020-11-05', 5, 125, 0),
('11867', 19, 118, '2020-11-05', 13, 325, 0),
('11868', 50, 118, '2020-11-05', 6, 150, 0),
('11869', 9, 118, '2020-11-05', 5, 125, 0),
('1187', 32, 118, '2020-11-03', 13, 325, 0),
('11870', 7, 118, '2020-11-05', 6, 150, 0),
('11871', 72, 118, '2020-11-05', 14, 350, 0),
('11872', 5, 118, '2020-11-05', 20, 500, 0),
('11873', 68, 118, '2020-11-05', 8, 200, 0),
('11874', 26, 118, '2020-11-05', 9, 225, 0),
('11875', 10, 118, '2020-11-05', 3, 75, 0),
('11876', 6, 118, '2020-11-05', 10, 250, 0),
('1188', 13, 118, '2020-11-03', 17, 425, 0),
('1189', 3, 118, '2020-11-03', 21, 525, 0),
('1191', 1, 119, '2020-11-05', 54, 1350, 0),
('11910', 54, 119, '2020-11-05', 103, 2575, 0),
('11911', 34, 119, '2020-11-05', 50, 1250, 0),
('11912', 46, 119, '2020-11-05', 13, 325, 0),
('11913', 7, 119, '2020-11-05', 15, 375, 0),
('11914', 21, 119, '2020-11-05', 10, 250, 0),
('11915', 24, 119, '2020-11-05', 8, 200, 0),
('11916', 20, 119, '2020-11-05', 10, 250, 0),
('11917', 3, 119, '2020-11-05', 42, 1050, 0),
('11918', 50, 119, '2020-11-05', 17, 425, 0),
('11919', 72, 119, '2020-11-05', 12, 300, 0),
('1192', 13, 119, '2020-11-05', 45, 1125, 0),
('11920', 5, 119, '2020-11-05', 15, 375, 0),
('11921', 33, 119, '2020-11-05', 43, 1075, 0),
('11922', 9, 119, '2020-11-05', 17, 425, 0),
('11923', 32, 119, '2020-11-05', 33, 825, 0),
('11924', 31, 119, '2020-11-05', 27, 675, 0),
('11925', 4, 119, '2020-11-05', 18, 450, 0),
('11926', 29, 119, '2020-11-05', 58, 1450, 0),
('11928', 38, 119, '2020-11-05', 28, 700, 0),
('11929', 30, 119, '2020-11-05', 56, 1400, 0),
('1193', 17, 119, '2020-11-05', 46, 1150, 0),
('11930', 68, 119, '2020-11-05', 11, 275, 0),
('11931', 10, 119, '2020-11-05', 7, 175, 0),
('11932', 14, 119, '2020-11-05', 8, 200, 0),
('1194', 16, 119, '2020-11-05', 30, 750, 0),
('1195', 2, 119, '2020-11-05', 58, 1450, 0),
('1196', 19, 119, '2020-11-05', 35, 875, 0),
('1197', 18, 119, '2020-11-05', 65, 1625, 0),
('1198', 15, 119, '2020-11-05', 23, 575, 0),
('1199', 6, 119, '2020-11-05', 32, 800, 0),
('1201', 1, 120, '2020-11-25', 24, 600, 0),
('12010', 34, 120, '2020-11-25', 20, 500, 0),
('12011', 7, 120, '2020-11-25', 8, 200, 0),
('12012', 21, 120, '2020-11-25', 15, 375, 0),
('12013', 24, 120, '2020-11-25', 12, 300, 0),
('12014', 20, 120, '2020-11-25', 14, 350, 0),
('12015', 3, 120, '2020-11-25', 20, 500, 0),
('12016', 50, 120, '2020-11-25', 9, 225, 0),
('12017', 72, 120, '2020-11-25', 9, 225, 0),
('12018', 33, 120, '2020-11-25', 16, 400, 0),
('12019', 9, 120, '2020-11-25', 9, 225, 0),
('1202', 13, 120, '2020-11-25', 18, 450, 0),
('12020', 32, 120, '2020-11-25', 14, 350, 0),
('12021', 31, 120, '2020-11-25', 17, 425, 0),
('12022', 4, 120, '2020-11-25', 8, 200, 0),
('12023', 29, 120, '2020-11-25', 23, 575, 0),
('12024', 26, 120, '2020-11-25', 11, 275, 0),
('12025', 30, 120, '2020-11-25', 23, 575, 0),
('12026', 22, 120, '2020-11-25', 12, 300, 0),
('12027', 10, 120, '2020-11-25', 3, 75, 0),
('12028', 27, 120, '2020-11-25', 9, 225, 0),
('12029', 5, 120, '2020-11-25', 10, 250, 0),
('1203', 17, 120, '2020-11-25', 20, 500, 0),
('12030', 10, 120, '2020-11-25', 4, 100, 0),
('12031', 14, 120, '2020-11-25', 11, 275, 0),
('12032', 2, 120, '2020-11-26', 22, 550, 0),
('12033', 1, 120, '2020-11-26', 21, 525, 0),
('12034', 54, 120, '2020-11-26', 34, 850, 0),
('12035', 33, 120, '2020-11-26', 16, 400, 0),
('12036', 4, 120, '2020-11-26', 9, 225, 0),
('12037', 17, 120, '2020-11-26', 20, 500, 0),
('12038', 6, 120, '2020-11-26', 4, 100, 0),
('12039', 34, 120, '2020-11-26', 21, 525, 0),
('1204', 16, 120, '2020-11-25', 15, 375, 0),
('12040', 18, 120, '2020-11-26', 25, 625, 0),
('12041', 19, 120, '2020-11-26', 19, 475, 0),
('12042', 29, 120, '2020-11-26', 23, 575, 0),
('12043', 30, 120, '2020-11-26', 23, 575, 0),
('12044', 15, 120, '2020-11-26', 12, 300, 0),
('12045', 13, 120, '2020-11-26', 18, 450, 0),
('12046', 16, 120, '2020-11-26', 13, 325, 0),
('12047', 3, 120, '2020-11-26', 17, 425, 0),
('12048', 32, 120, '2020-11-26', 11, 275, 0),
('12049', 50, 120, '2020-11-26', 9, 225, 0),
('1205', 2, 120, '2020-11-25', 24, 600, 0),
('12050', 72, 120, '2020-11-26', 11, 275, 0),
('12051', 9, 120, '2020-11-26', 7, 175, 0),
('12052', 7, 120, '2020-11-26', 9, 225, 0),
('12053', 27, 120, '2020-11-26', 11, 275, 0),
('12054', 20, 120, '2020-11-26', 10, 250, 0),
('12055', 26, 120, '2020-11-26', 11, 275, 0),
('12056', 31, 120, '2020-11-26', 15, 375, 0),
('12057', 21, 120, '2020-11-26', 11, 275, 0),
('12058', 22, 120, '2020-11-26', 10, 250, 0),
('12059', 24, 120, '2020-11-26', 9, 225, 0),
('1206', 19, 120, '2020-11-25', 16, 400, 0),
('12060', 14, 120, '2020-11-26', 6, 150, 0),
('12061', 10, 120, '2020-11-26', 4, 100, 0),
('12062', 5, 120, '2020-11-26', 10, 250, 0),
('12063', 2, 120, '2020-11-27', 6, 150, 0),
('12064', 1, 120, '2020-11-27', 7, 175, 0),
('12065', 54, 120, '2020-11-27', 14, 350, 0),
('12066', 33, 120, '2020-11-27', 6, 150, 0),
('12067', 4, 120, '2020-11-27', 5, 125, 0),
('12068', 17, 120, '2020-11-27', 9, 225, 0),
('12069', 34, 120, '2020-11-27', 4, 100, 0),
('1207', 18, 120, '2020-11-25', 22, 550, 0),
('12070', 18, 120, '2020-11-27', 8, 200, 0),
('12071', 19, 120, '2020-11-27', 4, 100, 0),
('12072', 29, 120, '2020-11-27', 7, 175, 0),
('12073', 30, 120, '2020-11-27', 7, 175, 0),
('12074', 13, 120, '2020-11-27', 4, 100, 0),
('12075', 3, 120, '2020-11-27', 7, 175, 0),
('12076', 32, 120, '2020-11-27', 4, 100, 0),
('12077', 50, 120, '2020-11-27', 4, 100, 0),
('12078', 27, 120, '2020-11-27', 4, 100, 0),
('12079', 26, 120, '2020-11-27', 4, 100, 0),
('1208', 15, 120, '2020-11-25', 12, 300, 0),
('1209', 54, 120, '2020-11-25', 36, 900, 0),
('1211', 1, 121, '2020-11-30', 54, 1350, 0),
('12110', 13, 121, '2020-11-30', 47, 1175, 0),
('12111', 16, 121, '2020-11-30', 31, 775, 0),
('12112', 15, 121, '2020-11-30', 23, 575, 0),
('12113', 3, 121, '2020-11-30', 38, 950, 0),
('12114', 33, 121, '2020-11-30', 37, 925, 0),
('12115', 72, 121, '2020-11-30', 23, 575, 0),
('12116', 31, 121, '2020-11-30', 32, 800, 0),
('12117', 30, 121, '2020-11-30', 53, 1325, 0),
('12118', 29, 121, '2020-11-30', 58, 1450, 0),
('12119', 9, 121, '2020-11-30', 19, 475, 0),
('1212', 2, 121, '2020-11-30', 59, 1475, 0),
('12120', 7, 121, '2020-11-30', 17, 425, 0),
('12121', 14, 121, '2020-11-30', 27, 675, 0),
('12122', 21, 121, '2020-11-30', 20, 500, 0),
('12123', 20, 121, '2020-11-30', 21, 525, 0),
('12124', 4, 121, '2020-11-30', 20, 500, 0),
('12125', 22, 121, '2020-11-30', 20, 500, 0),
('12126', 24, 121, '2020-11-30', 17, 425, 0),
('12127', 46, 121, '2020-11-30', 8, 200, 0),
('12128', 10, 121, '2020-11-30', 8, 200, 0),
('12129', 54, 121, '2020-11-30', 24, 600, 0),
('1213', 17, 121, '2020-11-30', 48, 1200, 0),
('12130', 5, 121, '2020-11-30', 10, 250, 0),
('1214', 18, 121, '2020-11-30', 68, 1700, 0),
('1215', 34, 121, '2020-11-30', 43, 1075, 0),
('1216', 26, 121, '2020-11-30', 29, 725, 0),
('1217', 19, 121, '2020-11-30', 40, 1000, 0),
('1218', 32, 121, '2020-11-30', 24, 600, 0),
('1219', 6, 121, '2020-11-30', 29, 725, 0),
('771', 1, 77, '2020-07-25', 60, 1500, 0),
('7710', 13, 77, '2020-07-25', 55, 1375, 0),
('7711', 14, 77, '2020-07-25', 5, 125, 0),
('7712', 15, 77, '2020-07-25', 21, 525, 0),
('7713', 17, 77, '2020-07-25', 35, 875, 0),
('7714', 18, 77, '2020-07-25', 70, 1750, 0),
('7715', 19, 77, '2020-07-25', 29, 725, 0),
('7716', 20, 77, '2020-07-25', 19, 475, 0),
('7717', 21, 77, '2020-07-25', 22, 550, 0),
('7718', 22, 77, '2020-07-25', 20, 500, 0),
('7719', 24, 77, '2020-07-25', 16, 400, 0),
('772', 2, 77, '2020-07-25', 62, 1550, 0),
('7720', 26, 77, '2020-07-25', 24, 600, 0),
('7721', 27, 77, '2020-07-25', 21, 525, 0),
('7722', 29, 77, '2020-07-25', 30, 750, 0),
('7723', 30, 77, '2020-07-25', 48, 1200, 0),
('7724', 31, 77, '2020-07-25', 35, 875, 0),
('7725', 32, 77, '2020-07-25', 24, 600, 0),
('7726', 33, 77, '2020-07-25', 55, 1375, 0),
('7727', 34, 77, '2020-07-25', 20, 500, 0),
('7728', 35, 77, '2020-07-25', 6, 150, 0),
('7729', 46, 77, '2020-07-25', 5, 125, 0),
('773', 3, 77, '2020-07-25', 50, 1250, 0),
('7730', 54, 77, '2020-07-25', 90, 2250, 0),
('7731', 83, 77, '2020-07-25', 21, 525, 0),
('774', 4, 77, '2020-07-25', 20, 500, 0),
('775', 7, 77, '2020-07-25', 15, 375, 0),
('776', 9, 77, '2020-07-25', 25, 625, 0),
('777', 10, 77, '2020-07-25', 6, 150, 0),
('778', 11, 77, '2020-07-25', 9, 225, 0),
('779', 12, 77, '2020-07-25', 5, 125, 0),
('781', 1, 78, '2020-07-25', 55, 1375, 0),
('7810', 15, 78, '2020-07-25', 25, 625, 0),
('7811', 17, 78, '2020-07-25', 30, 750, 0),
('7812', 18, 78, '2020-07-25', 80, 2000, 0),
('7813', 19, 78, '2020-07-25', 30, 750, 0),
('7814', 20, 78, '2020-07-25', 10, 250, 0),
('7815', 21, 78, '2020-07-25', 30, 750, 0),
('7816', 22, 78, '2020-07-25', 24, 600, 0),
('7817', 24, 78, '2020-07-25', 14, 350, 0),
('7818', 26, 78, '2020-07-25', 24, 600, 0),
('7819', 27, 78, '2020-07-25', 15, 375, 0),
('782', 2, 78, '2020-07-25', 57, 1425, 0),
('7820', 29, 78, '2020-07-25', 25, 625, 0),
('7821', 30, 78, '2020-07-25', 52, 1300, 0),
('7822', 31, 78, '2020-07-25', 30, 750, 0),
('7823', 32, 78, '2020-07-25', 25, 625, 0),
('7824', 33, 78, '2020-07-25', 50, 1250, 0),
('7825', 34, 78, '2020-07-25', 29, 725, 0),
('7826', 46, 78, '2020-07-25', 4, 100, 0),
('7827', 54, 78, '2020-07-25', 87, 2175, 0),
('7828', 72, 78, '2020-07-25', 28, 700, 0),
('7829', 83, 78, '2020-07-25', 32, 800, 0),
('783', 3, 78, '2020-07-25', 45, 1125, 0),
('784', 4, 78, '2020-07-25', 15, 375, 0),
('785', 7, 78, '2020-07-25', 8, 200, 0),
('786', 9, 78, '2020-07-25', 18, 450, 0),
('787', 10, 78, '2020-07-25', 6, 150, 0),
('788', 11, 78, '2020-07-25', 5, 125, 0),
('789', 13, 78, '2020-07-25', 45, 1125, 0),
('791', 1, 79, '2020-07-25', 52, 1300, 0),
('7910', 15, 79, '2020-07-25', 25, 625, 0),
('7911', 17, 79, '2020-07-25', 30, 750, 0),
('7912', 18, 79, '2020-07-25', 80, 2000, 0),
('7913', 19, 79, '2020-07-25', 30, 750, 0),
('7914', 20, 79, '2020-07-25', 10, 250, 0),
('7915', 21, 79, '2020-07-25', 30, 750, 0),
('7916', 22, 79, '2020-07-25', 24, 600, 0),
('7917', 24, 79, '2020-07-25', 14, 350, 0),
('7918', 26, 79, '2020-07-25', 24, 600, 0),
('7919', 27, 79, '2020-07-25', 15, 375, 0),
('792', 2, 79, '2020-07-25', 57, 1425, 0),
('7920', 29, 79, '2020-07-25', 25, 625, 0),
('7921', 30, 79, '2020-07-25', 52, 1300, 0),
('7922', 31, 79, '2020-07-25', 30, 750, 0),
('7923', 32, 79, '2020-07-25', 25, 625, 0),
('7924', 33, 79, '2020-07-25', 50, 1250, 0),
('7925', 34, 79, '2020-07-25', 29, 725, 0),
('7926', 46, 79, '2020-07-25', 4, 100, 0),
('7927', 54, 79, '2020-07-25', 87, 2175, 0),
('7928', 72, 79, '2020-07-25', 28, 700, 0),
('7929', 83, 79, '2020-07-25', 32, 800, 0),
('793', 3, 79, '2020-07-25', 45, 1125, 0),
('794', 4, 79, '2020-07-25', 15, 375, 0),
('795', 7, 79, '2020-07-25', 8, 200, 0),
('796', 9, 79, '2020-07-25', 18, 450, 0),
('797', 10, 79, '2020-07-25', 6, 150, 0),
('798', 11, 79, '2020-07-25', 5, 125, 0),
('799', 13, 79, '2020-07-25', 45, 1125, 0),
('801', 1, 80, '2020-07-28', 50, 1250, 0),
('8010', 15, 80, '2020-07-28', 22, 550, 0),
('8011', 17, 80, '2020-07-28', 30, 750, 0),
('8012', 18, 80, '2020-07-28', 80, 2000, 0),
('8013', 19, 80, '2020-07-28', 30, 750, 0),
('8014', 20, 80, '2020-07-28', 10, 250, 0),
('8015', 21, 80, '2020-07-28', 30, 750, 0),
('8016', 22, 80, '2020-07-28', 24, 600, 0),
('8017', 24, 80, '2020-07-28', 14, 350, 0),
('8018', 26, 80, '2020-07-28', 24, 600, 0),
('8019', 27, 80, '2020-07-28', 15, 375, 0),
('802', 2, 80, '2020-07-28', 52, 1300, 0),
('8020', 29, 80, '2020-07-28', 25, 625, 0),
('8021', 30, 80, '2020-07-28', 44, 1100, 0),
('8022', 31, 80, '2020-07-28', 30, 750, 0),
('8023', 32, 80, '2020-07-28', 22, 550, 0),
('8024', 33, 80, '2020-07-28', 40, 1000, 0),
('8025', 34, 80, '2020-07-28', 29, 725, 0),
('8026', 46, 80, '2020-07-28', 4, 100, 0),
('8027', 54, 80, '2020-07-28', 79, 1975, 0),
('8028', 72, 80, '2020-07-28', 20, 500, 0),
('8029', 83, 80, '2020-07-28', 32, 800, 0),
('803', 3, 80, '2020-07-28', 40, 1000, 0),
('804', 4, 80, '2020-07-28', 15, 375, 0),
('805', 7, 80, '2020-07-28', 8, 200, 0),
('806', 9, 80, '2020-07-28', 18, 450, 0),
('807', 10, 80, '2020-07-28', 6, 150, 0),
('808', 11, 80, '2020-07-28', 5, 125, 0),
('809', 13, 80, '2020-07-28', 50, 1250, 0),
('811', 1, 81, '2020-07-29', 40, 1000, 0),
('8110', 15, 81, '2020-07-29', 20, 500, 0),
('8111', 17, 81, '2020-07-29', 30, 750, 0),
('8112', 18, 81, '2020-07-29', 70, 1750, 0),
('8113', 19, 81, '2020-07-29', 30, 750, 0),
('8114', 20, 81, '2020-07-29', 10, 250, 0),
('8115', 21, 81, '2020-07-29', 27, 675, 0),
('8116', 22, 81, '2020-07-29', 22, 550, 0),
('8117', 24, 81, '2020-07-29', 14, 350, 0),
('8118', 26, 81, '2020-07-29', 21, 525, 0),
('8119', 27, 81, '2020-07-29', 15, 375, 0),
('812', 2, 81, '2020-07-29', 38, 950, 0),
('8120', 29, 81, '2020-07-29', 20, 500, 0),
('8121', 30, 81, '2020-07-29', 30, 750, 0),
('8122', 31, 81, '2020-07-29', 30, 750, 0),
('8123', 32, 81, '2020-07-29', 22, 550, 0),
('8124', 33, 81, '2020-07-29', 30, 750, 0),
('8125', 34, 81, '2020-07-29', 20, 500, 0),
('8126', 54, 81, '2020-07-29', 60, 1500, 0),
('8127', 72, 81, '2020-07-29', 15, 375, 0),
('8128', 83, 81, '2020-07-29', 21, 525, 0),
('813', 3, 81, '2020-07-29', 35, 875, 0),
('814', 4, 81, '2020-07-29', 15, 375, 0),
('815', 7, 81, '2020-07-29', 8, 200, 0),
('816', 9, 81, '2020-07-29', 18, 450, 0),
('817', 10, 81, '2020-07-29', 6, 150, 0),
('818', 11, 81, '2020-07-29', 5, 125, 0),
('819', 13, 81, '2020-07-29', 45, 1125, 0),
('821', 1, 82, '2020-07-30', 60, 1500, 0),
('8210', 13, 82, '2020-07-30', 55, 1375, 0),
('8211', 14, 82, '2020-07-30', 5, 125, 0),
('8212', 15, 82, '2020-07-30', 21, 525, 0),
('8213', 17, 82, '2020-07-30', 35, 875, 0),
('8214', 18, 82, '2020-07-30', 70, 1750, 0),
('8215', 19, 82, '2020-07-30', 29, 725, 0),
('8216', 20, 82, '2020-07-30', 19, 475, 0),
('8217', 21, 82, '2020-07-30', 22, 550, 0),
('8218', 22, 82, '2020-07-30', 29, 725, 0),
('8219', 24, 82, '2020-07-30', 16, 400, 0),
('822', 2, 82, '2020-07-30', 62, 1550, 0),
('8220', 26, 82, '2020-07-30', 24, 600, 0),
('8221', 27, 82, '2020-07-30', 21, 525, 0),
('8222', 29, 82, '2020-07-30', 30, 750, 0),
('8223', 30, 82, '2020-07-30', 48, 1200, 0),
('8224', 31, 82, '2020-07-30', 35, 875, 0),
('8225', 32, 82, '2020-07-30', 24, 600, 0),
('8226', 33, 82, '2020-07-30', 55, 1375, 0),
('8227', 34, 82, '2020-07-30', 20, 500, 0),
('8228', 35, 82, '2020-07-30', 6, 150, 0),
('8229', 46, 82, '2020-07-30', 5, 125, 0),
('823', 3, 82, '2020-07-30', 50, 1250, 0),
('8230', 54, 82, '2020-07-30', 90, 2250, 0),
('8231', 72, 82, '2020-07-30', 15, 375, 0),
('8232', 83, 82, '2020-07-30', 30, 750, 0),
('824', 4, 82, '2020-07-30', 20, 500, 0),
('825', 7, 82, '2020-07-30', 15, 375, 0),
('826', 9, 82, '2020-07-30', 25, 625, 0),
('827', 10, 82, '2020-07-30', 6, 150, 0),
('828', 11, 82, '2020-07-30', 9, 225, 0),
('829', 12, 82, '2020-07-30', 5, 125, 0),
('831', 1, 83, '2020-07-31', 60, 1500, 0),
('8310', 13, 83, '2020-07-31', 55, 1375, 0),
('8311', 14, 83, '2020-07-31', 5, 125, 0),
('8312', 15, 83, '2020-07-31', 21, 525, 0),
('8313', 17, 83, '2020-07-31', 35, 875, 0),
('8314', 18, 83, '2020-07-31', 70, 1750, 0),
('8315', 19, 83, '2020-07-31', 29, 725, 0),
('8316', 20, 83, '2020-07-31', 19, 475, 0),
('8317', 21, 83, '2020-07-31', 22, 550, 0),
('8318', 22, 83, '2020-07-31', 20, 500, 0),
('8319', 24, 83, '2020-07-31', 16, 400, 0),
('832', 2, 83, '2020-07-31', 60, 1500, 0),
('8320', 26, 83, '2020-07-31', 24, 600, 0),
('8321', 27, 83, '2020-07-31', 21, 525, 0),
('8322', 29, 83, '2020-07-31', 30, 750, 0),
('8323', 30, 83, '2020-07-31', 48, 1200, 0),
('8324', 31, 83, '2020-07-31', 35, 875, 0),
('8325', 32, 83, '2020-07-31', 24, 600, 0),
('8326', 33, 83, '2020-07-31', 55, 1375, 0),
('8327', 34, 83, '2020-07-31', 20, 500, 0),
('8328', 35, 83, '2020-07-31', 6, 150, 0),
('8329', 46, 83, '2020-07-31', 5, 125, 0),
('833', 3, 83, '2020-07-31', 50, 1250, 0),
('8330', 54, 83, '2020-07-31', 90, 2250, 0),
('8331', 72, 83, '2020-07-31', 10, 250, 0),
('8332', 83, 83, '2020-07-31', 26, 650, 0),
('834', 4, 83, '2020-07-31', 20, 500, 0),
('835', 7, 83, '2020-07-31', 15, 375, 0),
('836', 9, 83, '2020-07-31', 25, 625, 0),
('837', 10, 83, '2020-07-31', 6, 150, 0),
('838', 11, 83, '2020-07-31', 9, 225, 0),
('839', 12, 83, '2020-07-31', 5, 125, 0),
('841', 2, 84, '2020-08-01', 71, 1775, 0),
('8410', 13, 84, '2020-08-01', 29, 725, 0),
('8411', 44, 84, '2020-08-01', 40, 1000, 0),
('8412', 16, 84, '2020-08-01', 26, 650, 0),
('8413', 30, 84, '2020-08-01', 68, 1700, 0),
('8414', 56, 84, '2020-08-01', 18, 450, 0),
('8415', 33, 84, '2020-08-01', 50, 1250, 0),
('8416', 16, 84, '2020-08-01', 6, 150, 0),
('8417', 10, 84, '2020-08-01', 7, 175, 0),
('8418', 46, 84, '2020-08-01', 7, 175, 0),
('8419', 70, 84, '2020-08-01', 10, 250, 0),
('842', 1, 84, '2020-08-01', 53, 1325, 0),
('8420', 21, 84, '2020-08-01', 32, 800, 0),
('8421', 46, 84, '2020-08-01', 34, 850, 0),
('8422', 80, 84, '2020-08-01', 18, 450, 0),
('8423', 32, 84, '2020-08-01', 23, 575, 0),
('8424', 22, 84, '2020-08-01', 28, 700, 0),
('8425', 50, 84, '2020-08-01', 25, 625, 0),
('8426', 4, 84, '2020-08-01', 27, 675, 0),
('8427', 9, 84, '2020-08-01', 18, 450, 0),
('8428', 82, 84, '2020-08-01', 5, 125, 0),
('8429', 72, 84, '2020-08-01', 13, 325, 0),
('843', 19, 84, '2020-08-01', 52, 1300, 0),
('8430', 39, 84, '2020-08-01', 5, 125, 0),
('8431', 24, 84, '2020-08-01', 17, 425, 0),
('8432', 11, 84, '2020-08-01', 4, 100, 0),
('8433', 62, 84, '2020-08-01', 27, 675, 0),
('8434', 71, 84, '2020-08-01', 10, 250, 0),
('8435', 64, 84, '2020-08-01', 12, 300, 0),
('8436', 29, 84, '2020-08-01', 10, 250, 0),
('8437', 59, 84, '2020-08-01', 15, 375, 0),
('8438', 53, 84, '2020-08-01', 5, 125, 0),
('8439', 75, 84, '2020-08-01', 14, 350, 0),
('844', 61, 84, '2020-08-01', 20, 500, 0),
('845', 15, 84, '2020-08-01', 40, 1000, 0),
('846', 34, 84, '2020-08-01', 15, 375, 0),
('847', 54, 84, '2020-08-01', 31, 775, 0),
('848', 31, 84, '2020-08-01', 52, 1300, 0),
('849', 17, 84, '2020-08-01', 45, 1125, 0),
('851', 34, 85, '2020-08-02', 37, 925, 0),
('8510', 75, 85, '2020-08-02', 10, 250, 0),
('8511', 18, 85, '2020-08-02', 59, 1475, 0),
('8512', 4, 85, '2020-08-02', 27, 675, 0),
('8513', 1, 85, '2020-08-02', 40, 1000, 0),
('8514', 64, 85, '2020-08-02', 21, 525, 0),
('8515', 61, 85, '2020-08-02', 23, 575, 0),
('8516', 42, 85, '2020-08-02', 33, 825, 0),
('8517', 79, 85, '2020-08-02', 27, 675, 0),
('8518', 15, 85, '2020-08-02', 30, 750, 0),
('8519', 39, 85, '2020-08-02', 17, 425, 0),
('852', 54, 85, '2020-08-02', 69, 1725, 0),
('8520', 56, 85, '2020-08-02', 27, 675, 0),
('8521', 44, 85, '2020-08-02', 23, 575, 0),
('8522', 22, 85, '2020-08-02', 18, 450, 0),
('8523', 21, 85, '2020-08-02', 34, 850, 0),
('8524', 71, 85, '2020-08-02', 9, 225, 0),
('8525', 13, 85, '2020-08-02', 25, 625, 0),
('8526', 80, 85, '2020-08-02', 16, 400, 0),
('8527', 59, 85, '2020-08-02', 7, 175, 0),
('8528', 16, 85, '2020-08-02', 18, 450, 0),
('8529', 82, 85, '2020-08-02', 14, 350, 0),
('853', 30, 85, '2020-08-02', 38, 950, 0),
('8530', 72, 85, '2020-08-02', 13, 325, 0),
('8531', 64, 85, '2020-08-02', 9, 225, 0),
('8532', 9, 85, '2020-08-02', 12, 300, 0),
('8533', 24, 85, '2020-08-02', 14, 350, 0),
('8534', 10, 85, '2020-08-02', 7, 175, 0),
('8535', 11, 85, '2020-08-02', 7, 175, 0),
('854', 17, 85, '2020-08-02', 42, 1050, 0),
('855', 2, 85, '2020-08-02', 46, 1150, 0),
('856', 29, 85, '2020-08-02', 25, 625, 0),
('857', 33, 85, '2020-08-02', 44, 1100, 0),
('858', 31, 85, '2020-08-02', 27, 675, 0),
('859', 32, 85, '2020-08-02', 2, 50, 0),
('861', 1, 86, '2020-08-03', 108, 2700, 0),
('8610', 4, 86, '2020-08-03', 23, 575, 0),
('8611', 64, 86, '2020-08-03', 22, 550, 0),
('8612', 15, 86, '2020-08-03', 30, 750, 0),
('8613', 13, 86, '2020-08-03', 35, 875, 0),
('8614', 44, 86, '2020-08-03', 30, 750, 0),
('8615', 79, 86, '2020-08-03', 24, 600, 0),
('8616', 31, 86, '2020-08-03', 40, 1000, 0),
('8617', 32, 86, '2020-08-03', 29, 725, 0),
('8618', 56, 86, '2020-08-03', 21, 525, 0),
('8619', 42, 86, '2020-08-03', 25, 625, 0),
('862', 2, 86, '2020-08-03', 54, 1350, 0),
('8620', 38, 86, '2020-08-03', 10, 250, 0),
('8621', 46, 86, '2020-08-03', 11, 275, 0),
('8622', 9, 86, '2020-08-03', 18, 450, 0),
('8623', 21, 86, '2020-08-03', 36, 900, 0),
('8624', 72, 86, '2020-08-03', 15, 375, 0),
('8625', 22, 86, '2020-08-03', 21, 525, 0),
('8626', 24, 86, '2020-08-03', 19, 475, 0),
('8627', 48, 86, '2020-08-03', 10, 250, 0),
('8628', 80, 86, '2020-08-03', 16, 400, 0),
('8629', 10, 86, '2020-08-03', 2, 50, 0),
('863', 30, 86, '2020-08-03', 54, 1350, 0),
('8630', 11, 86, '2020-08-03', 16, 400, 0),
('8631', 29, 86, '2020-08-03', 15, 375, 0),
('8632', 39, 86, '2020-08-03', 7, 175, 0),
('8633', 16, 86, '2020-08-03', 4, 100, 0),
('8634', 70, 86, '2020-08-03', 4, 100, 0),
('8635', 16, 86, '2020-08-03', 4, 100, 0),
('864', 17, 86, '2020-08-03', 51, 1275, 0),
('865', 34, 86, '2020-08-03', 35, 875, 0),
('866', 18, 86, '2020-08-03', 61, 1525, 0),
('867', 54, 86, '2020-08-03', 79, 1975, 0),
('868', 61, 86, '2020-08-03', 28, 700, 0),
('869', 33, 86, '2020-08-03', 46, 1150, 0),
('871', 1, 87, '2020-08-04', 51, 1275, 0),
('8710', 42, 87, '2020-08-04', 48, 1200, 0),
('8711', 61, 87, '2020-08-04', 24, 600, 0),
('8712', 68, 87, '2020-08-04', 48, 1200, 0),
('8713', 54, 87, '2020-08-04', 53, 1325, 0),
('8714', 44, 87, '2020-08-04', 16, 400, 0),
('8715', 33, 87, '2020-08-04', 39, 975, 0),
('8716', 9, 87, '2020-08-04', 18, 450, 0),
('8717', 21, 87, '2020-08-04', 45, 1125, 0),
('8718', 22, 87, '2020-08-04', 26, 650, 0),
('8719', 31, 87, '2020-08-04', 44, 1100, 0),
('872', 2, 87, '2020-08-04', 54, 1350, 0),
('8720', 64, 87, '2020-08-04', 7, 175, 0),
('8721', 72, 87, '2020-08-04', 21, 525, 0),
('8722', 38, 87, '2020-08-04', 23, 575, 0),
('8723', 24, 87, '2020-08-04', 14, 350, 0),
('8724', 39, 87, '2020-08-04', 14, 350, 0),
('8725', 57, 87, '2020-08-04', 3, 75, 0),
('8726', 11, 87, '2020-08-04', 10, 250, 0),
('8727', 19, 87, '2020-08-04', 32, 800, 0),
('8728', 29, 87, '2020-08-04', 24, 600, 0),
('8729', 83, 87, '2020-08-04', 15, 375, 0),
('873', 30, 87, '2020-08-04', 35, 875, 0),
('8730', 4, 87, '2020-08-04', 3, 75, 0),
('8731', 35, 87, '2020-08-04', 2, 50, 0),
('874', 17, 87, '2020-08-04', 57, 1425, 0),
('875', 34, 87, '2020-08-04', 35, 875, 0),
('876', 18, 87, '2020-08-04', 58, 1450, 0),
('877', 49, 87, '2020-08-04', 6, 150, 0),
('878', 13, 87, '2020-08-04', 41, 1025, 0),
('879', 32, 87, '2020-08-04', 33, 825, 0),
('881', 1, 88, '2020-08-05', 57, 1425, 0),
('8810', 29, 88, '2020-08-05', 48, 1200, 0),
('8811', 54, 88, '2020-08-05', 89, 2225, 0),
('8812', 61, 88, '2020-08-05', 27, 675, 0),
('8813', 42, 88, '2020-08-05', 54, 1350, 0),
('8814', 34, 88, '2020-08-05', 37, 925, 0),
('8815', 32, 88, '2020-08-05', 30, 750, 0),
('8816', 79, 88, '2020-08-05', 33, 825, 0),
('8817', 31, 88, '2020-08-05', 49, 1225, 0),
('8818', 83, 88, '2020-08-05', 0, 0, 0),
('8819', 68, 88, '2020-08-05', 26, 650, 0),
('882', 2, 88, '2020-08-05', 65, 1625, 0),
('8820', 64, 88, '2020-08-05', 12, 300, 0),
('8821', 9, 88, '2020-08-05', 17, 425, 0),
('8822', 21, 88, '2020-08-05', 36, 900, 0),
('8823', 22, 88, '2020-08-05', 19, 475, 0),
('8824', 39, 88, '2020-08-05', 12, 300, 0),
('8825', 72, 88, '2020-08-05', 25, 625, 0),
('8826', 11, 88, '2020-08-05', 7, 175, 0),
('8827', 82, 88, '2020-08-05', 7, 175, 0),
('8828', 19, 88, '2020-08-05', 20, 500, 0),
('8829', 17, 88, '2020-08-05', 44, 1100, 0),
('883', 30, 88, '2020-08-05', 63, 1575, 0),
('8830', 38, 88, '2020-08-05', 6, 150, 0),
('884', 18, 88, '2020-08-05', 86, 2150, 0),
('885', 33, 88, '2020-08-05', 46, 1150, 0),
('886', 4, 88, '2020-08-05', 10, 250, 0),
('887', 15, 88, '2020-08-05', 16, 400, 0),
('888', 68, 88, '2020-08-05', 27, 675, 0),
('889', 13, 88, '2020-08-05', 37, 925, 0),
('891', 1, 89, '2020-08-06', 49, 1225, 0),
('8910', 29, 89, '2020-08-06', 30, 750, 0),
('8911', 54, 89, '2020-08-06', 61, 1525, 0),
('8912', 61, 89, '2020-08-06', 20, 500, 0),
('8913', 42, 89, '2020-08-06', 40, 1000, 0),
('8914', 34, 89, '2020-08-06', 24, 600, 0);
INSERT INTO `bolsas_pelador` (`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`, `estado`) VALUES
('8915', 32, 89, '2020-08-06', 27, 675, 0),
('8916', 79, 89, '2020-08-06', 10, 250, 0),
('8917', 64, 89, '2020-08-06', 14, 350, 0),
('8918', 22, 89, '2020-08-06', 19, 475, 0),
('8919', 17, 89, '2020-08-06', 59, 1475, 0),
('892', 2, 89, '2020-08-06', 56, 1400, 0),
('8920', 16, 89, '2020-08-06', 20, 500, 0),
('8921', 38, 89, '2020-08-06', 23, 575, 0),
('8922', 21, 89, '2020-08-06', 35, 875, 0),
('8923', 44, 89, '2020-08-06', 32, 800, 0),
('8924', 31, 89, '2020-08-06', 24, 600, 0),
('8925', 72, 89, '2020-08-06', 23, 575, 0),
('8926', 24, 89, '2020-08-06', 14, 350, 0),
('8927', 83, 89, '2020-08-06', 26, 650, 0),
('8928', 9, 89, '2020-08-06', 16, 400, 0),
('8929', 39, 89, '2020-08-06', 14, 350, 0),
('893', 30, 89, '2020-08-06', 53, 1325, 0),
('8930', 11, 89, '2020-08-06', 3, 75, 0),
('8931', 18, 89, '2020-08-06', 8, 200, 0),
('8932', 82, 89, '2020-08-06', 5, 125, 0),
('8933', 19, 89, '2020-08-06', 15, 375, 0),
('894', 66, 89, '2020-08-06', 64, 1600, 0),
('895', 33, 89, '2020-08-06', 45, 1125, 0),
('896', 4, 89, '2020-08-06', 28, 700, 0),
('897', 15, 89, '2020-08-06', 19, 475, 0),
('898', 68, 89, '2020-08-06', 36, 900, 0),
('899', 13, 89, '2020-08-06', 39, 975, 0),
('901', 1, 90, '2020-08-07', 47, 1175, 0),
('9010', 68, 90, '2020-08-07', 35, 875, 0),
('9011', 31, 90, '2020-08-07', 40, 1000, 0),
('9012', 73, 90, '2020-08-07', 34, 850, 0),
('9013', 4, 90, '2020-08-07', 20, 500, 0),
('9014', 64, 90, '2020-08-07', 15, 375, 0),
('9015', 34, 90, '2020-08-07', 34, 850, 0),
('9016', 32, 90, '2020-08-07', 30, 750, 0),
('9017', 16, 90, '2020-08-07', 24, 600, 0),
('9018', 46, 90, '2020-08-07', 16, 400, 0),
('9019', 52, 90, '2020-08-07', 4, 100, 0),
('902', 2, 90, '2020-08-07', 49, 1225, 0),
('9020', 38, 90, '2020-08-07', 23, 575, 0),
('9021', 22, 90, '2020-08-07', 20, 500, 0),
('9022', 21, 90, '2020-08-07', 38, 950, 0),
('9023', 72, 90, '2020-08-07', 24, 600, 0),
('9024', 24, 90, '2020-08-07', 14, 350, 0),
('9025', 44, 90, '2020-08-07', 28, 700, 0),
('9026', 39, 90, '2020-08-07', 14, 350, 0),
('9027', 61, 90, '2020-08-07', 23, 575, 0),
('9028', 11, 90, '2020-08-07', 4, 100, 0),
('9029', 83, 90, '2020-08-07', 25, 625, 0),
('903', 30, 90, '2020-08-07', 43, 1075, 0),
('9030', 19, 90, '2020-08-07', 48, 1200, 0),
('9031', 43, 90, '2020-08-07', 19, 475, 0),
('9032', 9, 90, '2020-08-07', 15, 375, 0),
('9033', 82, 90, '2020-08-07', 14, 350, 0),
('9034', 18, 90, '2020-08-07', 7, 175, 0),
('9035', 15, 90, '2020-08-07', 6, 150, 0),
('9036', 53, 90, '2020-08-07', 1, 25, 0),
('904', 18, 90, '2020-08-07', 40, 1000, 0),
('905', 33, 90, '2020-08-07', 45, 1125, 0),
('906', 42, 90, '2020-08-07', 37, 925, 0),
('907', 17, 90, '2020-08-07', 50, 1250, 0),
('908', 13, 90, '2020-08-07', 31, 775, 0),
('909', 54, 90, '2020-08-07', 60, 1500, 0),
('911', 1, 91, '2020-08-08', 64, 1600, 0),
('9110', 21, 91, '2020-08-08', 35, 875, 0),
('9111', 54, 91, '2020-08-08', 65, 1625, 0),
('9112', 61, 91, '2020-08-08', 22, 550, 0),
('9113', 33, 91, '2020-08-08', 54, 1350, 0),
('9114', 4, 91, '2020-08-08', 12, 300, 0),
('9115', 34, 91, '2020-08-08', 30, 750, 0),
('9116', 30, 91, '2020-08-08', 57, 1425, 0),
('9117', 29, 91, '2020-08-08', 37, 925, 0),
('9118', 24, 91, '2020-08-08', 20, 500, 0),
('9119', 38, 91, '2020-08-08', 28, 700, 0),
('912', 2, 91, '2020-08-08', 70, 1750, 0),
('9120', 44, 91, '2020-08-08', 24, 600, 0),
('9121', 83, 91, '2020-08-08', 33, 825, 0),
('9122', 43, 91, '2020-08-08', 33, 825, 0),
('9123', 46, 91, '2020-08-08', 8, 200, 0),
('9124', 72, 91, '2020-08-08', 17, 425, 0),
('9125', 9, 91, '2020-08-08', 22, 550, 0),
('9126', 18, 91, '2020-08-08', 21, 525, 0),
('9127', 19, 91, '2020-08-08', 62, 1550, 0),
('9128', 16, 91, '2020-08-08', 10, 250, 0),
('913', 17, 91, '2020-08-08', 60, 1500, 0),
('914', 16, 91, '2020-08-08', 32, 800, 0),
('915', 13, 91, '2020-08-08', 34, 850, 0),
('916', 15, 91, '2020-08-08', 10, 250, 0),
('917', 68, 91, '2020-08-08', 32, 800, 0),
('918', 66, 91, '2020-08-08', 60, 1500, 0),
('919', 22, 91, '2020-08-08', 25, 625, 0),
('921', 1, 92, '2020-08-09', 66, 1650, 0),
('9210', 54, 92, '2020-08-09', 111, 2775, 0),
('9211', 21, 92, '2020-08-09', 34, 850, 0),
('9212', 22, 92, '2020-08-09', 2, 50, 0),
('9213', 24, 92, '2020-08-09', 22, 550, 0),
('9214', 31, 92, '2020-08-09', 46, 1150, 0),
('9215', 43, 92, '2020-08-09', 27, 675, 0),
('9216', 32, 92, '2020-08-09', 38, 950, 0),
('9217', 61, 92, '2020-08-09', 1, 25, 0),
('9218', 83, 92, '2020-08-09', 23, 575, 0),
('9219', 38, 92, '2020-08-09', 34, 850, 0),
('922', 2, 92, '2020-08-09', 69, 1725, 0),
('9220', 46, 92, '2020-08-09', 9, 225, 0),
('9221', 72, 92, '2020-08-09', 26, 650, 0),
('9222', 42, 92, '2020-08-09', 12, 300, 0),
('9223', 9, 92, '2020-08-09', 19, 475, 0),
('9224', 19, 92, '2020-08-09', 50, 1250, 0),
('9225', 68, 92, '2020-08-09', 24, 600, 0),
('9226', 18, 92, '2020-08-09', 9, 225, 0),
('9227', 44, 92, '2020-08-09', 17, 425, 0),
('923', 17, 92, '2020-08-09', 60, 1500, 0),
('924', 16, 92, '2020-08-09', 28, 700, 0),
('925', 30, 92, '2020-08-09', 57, 1425, 0),
('926', 29, 92, '2020-08-09', 34, 850, 0),
('927', 15, 92, '2020-08-09', 26, 650, 0),
('928', 13, 92, '2020-08-09', 45, 1125, 0),
('929', 34, 92, '2020-08-09', 41, 1025, 0),
('931', 33, 93, '2020-08-10', 32, 800, 0),
('9310', 4, 93, '2020-08-10', 15, 375, 0),
('9311', 30, 93, '2020-08-10', 54, 1350, 0),
('9312', 64, 93, '2020-08-10', 14, 350, 0),
('9313', 29, 93, '2020-08-10', 36, 900, 0),
('9314', 38, 93, '2020-08-10', 35, 875, 0),
('9315', 16, 93, '2020-08-10', 20, 500, 0),
('9316', 78, 93, '2020-08-10', 30, 750, 0),
('9317', 70, 93, '2020-08-10', 13, 325, 0),
('9318', 15, 93, '2020-08-10', 15, 375, 0),
('9319', 18, 93, '2020-08-10', 40, 1000, 0),
('932', 2, 93, '2020-08-10', 64, 1600, 0),
('9320', 9, 93, '2020-08-10', 19, 475, 0),
('9321', 83, 93, '2020-08-10', 14, 350, 0),
('9322', 46, 93, '2020-08-10', 19, 475, 0),
('9323', 18, 93, '2020-08-10', 15, 375, 0),
('9324', 21, 93, '2020-08-10', 23, 575, 0),
('9325', 22, 93, '2020-08-10', 17, 425, 0),
('9326', 44, 93, '2020-08-10', 30, 750, 0),
('9327', 52, 93, '2020-08-10', 5, 125, 0),
('9328', 58, 93, '2020-08-10', 8, 200, 0),
('9329', 19, 93, '2020-08-10', 50, 1250, 0),
('933', 1, 93, '2020-08-10', 60, 1500, 0),
('9330', 24, 93, '2020-08-10', 6, 150, 0),
('934', 31, 93, '2020-08-10', 47, 1175, 0),
('935', 68, 93, '2020-08-10', 38, 950, 0),
('936', 13, 93, '2020-08-10', 42, 1050, 0),
('937', 32, 93, '2020-08-10', 20, 500, 0),
('938', 34, 93, '2020-08-10', 49, 1225, 0),
('939', 54, 93, '2020-08-10', 10, 250, 0),
('941', 1, 94, '2020-08-11', 60, 1500, 0),
('9410', 13, 94, '2020-08-11', 55, 1375, 0),
('9411', 14, 94, '2020-08-11', 5, 125, 0),
('9412', 15, 94, '2020-08-11', 21, 525, 0),
('9413', 17, 94, '2020-08-11', 35, 875, 0),
('9414', 18, 94, '2020-08-11', 70, 1750, 0),
('9415', 19, 94, '2020-08-11', 29, 725, 0),
('9416', 20, 94, '2020-08-11', 19, 475, 0),
('9417', 21, 94, '2020-08-11', 22, 550, 0),
('9418', 22, 94, '2020-08-11', 20, 500, 0),
('9419', 24, 94, '2020-08-11', 16, 400, 0),
('942', 2, 94, '2020-08-11', 65, 1625, 0),
('9420', 26, 94, '2020-08-11', 24, 600, 0),
('9421', 27, 94, '2020-08-11', 21, 525, 0),
('9422', 29, 94, '2020-08-11', 30, 750, 0),
('9423', 30, 94, '2020-08-11', 48, 1200, 0),
('9424', 31, 94, '2020-08-11', 35, 875, 0),
('9425', 32, 94, '2020-08-11', 24, 600, 0),
('9426', 33, 94, '2020-08-11', 55, 1375, 0),
('9427', 34, 94, '2020-08-11', 20, 500, 0),
('9428', 35, 94, '2020-08-11', 6, 150, 0),
('9429', 46, 94, '2020-08-11', 5, 125, 0),
('943', 3, 94, '2020-08-11', 55, 1375, 0),
('9430', 54, 94, '2020-08-11', 98, 2450, 0),
('9431', 72, 94, '2020-08-11', 15, 375, 0),
('9432', 83, 94, '2020-08-11', 30, 750, 0),
('944', 4, 94, '2020-08-11', 22, 550, 0),
('945', 7, 94, '2020-08-11', 15, 375, 0),
('946', 9, 94, '2020-08-11', 28, 700, 0),
('947', 10, 94, '2020-08-11', 6, 150, 0),
('948', 11, 94, '2020-08-11', 9, 225, 0),
('949', 12, 94, '2020-08-11', 5, 125, 0),
('951', 1, 95, '2020-08-12', 60, 1500, 0),
('9510', 64, 95, '2020-08-12', 4, 100, 0),
('9511', 68, 95, '2020-08-12', 20, 500, 0),
('9512', 34, 95, '2020-08-12', 40, 1000, 0),
('9513', 29, 95, '2020-08-12', 50, 1250, 0),
('9514', 21, 95, '2020-08-12', 27, 675, 0),
('9515', 31, 95, '2020-08-12', 41, 1025, 0),
('9516', 43, 95, '2020-08-12', 28, 700, 0),
('9517', 38, 95, '2020-08-12', 33, 825, 0),
('9518', 32, 95, '2020-08-12', 30, 750, 0),
('9519', 16, 95, '2020-08-12', 24, 600, 0),
('952', 2, 95, '2020-08-12', 63, 1575, 0),
('9520', 46, 95, '2020-08-12', 19, 475, 0),
('9521', 18, 95, '2020-08-12', 22, 550, 0),
('9522', 22, 95, '2020-08-12', 19, 475, 0),
('9523', 9, 95, '2020-08-12', 21, 525, 0),
('9524', 72, 95, '2020-08-12', 39, 975, 0),
('9525', 58, 95, '2020-08-12', 12, 300, 0),
('9526', 19, 95, '2020-08-12', 61, 1525, 0),
('9527', 2, 95, '2020-08-12', 5, 125, 0),
('9528', 18, 95, '2020-08-12', 0, 0, 0),
('9529', 24, 95, '2020-08-12', 14, 350, 0),
('953', 15, 95, '2020-08-12', 24, 600, 0),
('9530', 61, 95, '2020-08-12', 11, 275, 0),
('9531', 42, 95, '2020-08-12', 12, 300, 0),
('9532', 83, 95, '2020-08-12', 15, 375, 0),
('954', 13, 95, '2020-08-12', 40, 1000, 0),
('955', 18, 95, '2020-08-12', 60, 1500, 0),
('956', 30, 95, '2020-08-12', 64, 1600, 0),
('957', 54, 95, '2020-08-12', 48, 1200, 0),
('958', 33, 95, '2020-08-12', 35, 875, 0),
('959', 4, 95, '2020-08-12', 35, 875, 0),
('961', 34, 96, '2020-08-13', 31, 775, 0),
('9610', 38, 96, '2020-08-13', 31, 775, 0),
('9611', 42, 96, '2020-08-13', 28, 700, 0),
('9612', 17, 96, '2020-08-13', 43, 1075, 0),
('9613', 13, 96, '2020-08-13', 33, 825, 0),
('9614', 32, 96, '2020-08-13', 24, 600, 0),
('9615', 16, 96, '2020-08-13', 24, 600, 0),
('9616', 72, 96, '2020-08-13', 47, 1175, 0),
('9617', 4, 96, '2020-08-13', 22, 550, 0),
('9618', 31, 96, '2020-08-13', 34, 850, 0),
('9619', 29, 96, '2020-08-13', 51, 1275, 0),
('962', 2, 96, '2020-08-13', 52, 1300, 0),
('9620', 43, 96, '2020-08-13', 21, 525, 0),
('9621', 9, 96, '2020-08-13', 18, 450, 0),
('9622', 83, 96, '2020-08-13', 9, 225, 0),
('9623', 18, 96, '2020-08-13', 17, 425, 0),
('9624', 21, 96, '2020-08-13', 32, 800, 0),
('9625', 22, 96, '2020-08-13', 20, 500, 0),
('9626', 24, 96, '2020-08-13', 16, 400, 0),
('9627', 64, 96, '2020-08-13', 5, 125, 0),
('9628', 69, 96, '2020-08-13', 10, 250, 0),
('9629', 27, 96, '2020-08-13', 10, 250, 0),
('963', 54, 96, '2020-08-13', 77, 1925, 0),
('9630', 19, 96, '2020-08-13', 42, 1050, 0),
('9631', 15, 96, '2020-08-13', 24, 600, 0),
('964', 33, 96, '2020-08-13', 44, 1100, 0),
('965', 1, 96, '2020-08-13', 47, 1175, 0),
('966', 18, 96, '2020-08-13', 51, 1275, 0),
('967', 4, 96, '2020-08-13', 26, 650, 0),
('968', 30, 96, '2020-08-13', 52, 1300, 0),
('969', 68, 96, '2020-08-13', 25, 625, 0),
('971', 18, 97, '2020-08-14', 40, 1000, 0),
('9710', 32, 97, '2020-08-14', 30, 750, 0),
('9711', 4, 97, '2020-08-14', 32, 800, 0),
('9712', 29, 97, '2020-08-14', 34, 850, 0),
('9713', 34, 97, '2020-08-14', 37, 925, 0),
('9714', 46, 97, '2020-08-14', 10, 250, 0),
('9715', 16, 97, '2020-08-14', 24, 600, 0),
('9716', 21, 97, '2020-08-14', 37, 925, 0),
('9717', 15, 97, '2020-08-14', 33, 825, 0),
('9718', 22, 97, '2020-08-14', 20, 500, 0),
('9719', 83, 97, '2020-08-14', 33, 825, 0),
('972', 30, 97, '2020-08-14', 41, 1025, 0),
('9720', 43, 97, '2020-08-14', 31, 775, 0),
('9721', 24, 97, '2020-08-14', 14, 350, 0),
('9722', 9, 97, '2020-08-14', 21, 525, 0),
('9723', 68, 97, '2020-08-14', 33, 825, 0),
('9724', 69, 97, '2020-08-14', 14, 350, 0),
('9725', 27, 97, '2020-08-14', 13, 325, 0),
('9726', 58, 97, '2020-08-14', 6, 150, 0),
('9727', 8, 97, '2020-08-14', 17, 425, 0),
('9728', 19, 97, '2020-08-14', 50, 1250, 0),
('9729', 37, 97, '2020-08-14', 7, 175, 0),
('973', 2, 97, '2020-08-14', 62, 1550, 0),
('9730', 72, 97, '2020-08-14', 12, 300, 0),
('9731', 18, 97, '2020-08-14', 12, 300, 0),
('974', 33, 97, '2020-08-14', 44, 1100, 0),
('975', 1, 97, '2020-08-14', 61, 1525, 0),
('976', 31, 97, '2020-08-14', 42, 1050, 0),
('977', 13, 97, '2020-08-14', 48, 1200, 0),
('978', 17, 97, '2020-08-14', 58, 1450, 0),
('979', 38, 97, '2020-08-14', 32, 800, 0),
('981', 18, 98, '2020-08-15', 46, 1150, 0),
('9810', 38, 98, '2020-08-15', 24, 600, 0),
('9811', 1, 98, '2020-08-15', 36, 900, 0),
('9812', 22, 98, '2020-08-15', 18, 450, 0),
('9813', 21, 98, '2020-08-15', 36, 900, 0),
('9814', 16, 98, '2020-08-15', 20, 500, 0),
('9815', 54, 98, '2020-08-15', 63, 1575, 0),
('9816', 34, 98, '2020-08-15', 20, 500, 0),
('9817', 43, 98, '2020-08-15', 9, 225, 0),
('9818', 32, 98, '2020-08-15', 20, 500, 0),
('9819', 83, 98, '2020-08-15', 8, 200, 0),
('982', 2, 98, '2020-08-15', 46, 1150, 0),
('9820', 46, 98, '2020-08-15', 16, 400, 0),
('9821', 64, 98, '2020-08-15', 15, 375, 0),
('9822', 72, 98, '2020-08-15', 18, 450, 0),
('9823', 18, 98, '2020-08-15', 16, 400, 0),
('9824', 24, 98, '2020-08-15', 18, 450, 0),
('9825', 7, 98, '2020-08-15', 24, 600, 0),
('9826', 37, 98, '2020-08-15', 5, 125, 0),
('9827', 69, 98, '2020-08-15', 13, 325, 0),
('9828', 27, 98, '2020-08-15', 12, 300, 0),
('9829', 9, 98, '2020-08-15', 13, 325, 0),
('983', 33, 98, '2020-08-15', 36, 900, 0),
('9830', 8, 98, '2020-08-15', 16, 400, 0),
('9831', 50, 98, '2020-08-15', 16, 400, 0),
('9832', 19, 98, '2020-08-15', 27, 675, 0),
('9833', 35, 98, '2020-08-15', 5, 125, 0),
('984', 29, 98, '2020-08-15', 14, 350, 0),
('985', 31, 98, '2020-08-15', 24, 600, 0),
('986', 68, 98, '2020-08-15', 38, 950, 0),
('987', 17, 98, '2020-08-15', 42, 1050, 0),
('988', 13, 98, '2020-08-15', 28, 700, 0),
('989', 4, 98, '2020-08-15', 26, 650, 0),
('991', 2, 99, '2020-08-16', 49, 1225, 0),
('9910', 26, 99, '2020-08-16', 9, 225, 0),
('9911', 15, 99, '2020-08-16', 27, 675, 0),
('9912', 18, 99, '2020-08-16', 49, 1225, 0),
('9913', 16, 99, '2020-08-16', 24, 600, 0),
('9914', 30, 99, '2020-08-16', 40, 1000, 0),
('9915', 31, 99, '2020-08-16', 32, 800, 0),
('9916', 43, 99, '2020-08-16', 25, 625, 0),
('9917', 29, 99, '2020-08-16', 42, 1050, 0),
('9918', 83, 99, '2020-08-16', 28, 700, 0),
('9919', 32, 99, '2020-08-16', 24, 600, 0),
('992', 1, 99, '2020-08-16', 48, 1200, 0),
('9920', 8, 99, '2020-08-16', 21, 525, 0),
('9921', 21, 99, '2020-08-16', 42, 1050, 0),
('9922', 24, 99, '2020-08-16', 3, 75, 0),
('9923', 9, 99, '2020-08-16', 19, 475, 0),
('9924', 7, 99, '2020-08-16', 20, 500, 0),
('9925', 72, 99, '2020-08-16', 16, 400, 0),
('9926', 22, 99, '2020-08-16', 21, 525, 0),
('9927', 18, 99, '2020-08-16', 19, 475, 0),
('9928', 46, 99, '2020-08-16', 19, 475, 0),
('9929', 27, 99, '2020-08-16', 14, 350, 0),
('993', 33, 99, '2020-08-16', 43, 1075, 0),
('9930', 58, 99, '2020-08-16', 13, 325, 0),
('9931', 38, 99, '2020-08-16', 4, 100, 0),
('9932', 69, 99, '2020-08-16', 15, 375, 0),
('9933', 19, 99, '2020-08-16', 22, 550, 0),
('9934', 35, 99, '2020-08-16', 5, 125, 0),
('9935', 74, 99, '2020-08-16', 6, 150, 0),
('994', 4, 99, '2020-08-16', 52, 1300, 0),
('995', 64, 99, '2020-08-16', 13, 325, 0),
('996', 13, 99, '2020-08-16', 32, 800, 0),
('997', 17, 99, '2020-08-16', 58, 1450, 0),
('998', 54, 99, '2020-08-16', 57, 1425, 0),
('999', 34, 99, '2020-08-16', 36, 900, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_toston`
--

DROP TABLE IF EXISTS `bolsas_toston`;
CREATE TABLE `bolsas_toston` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_planilla` int(11) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `diaUno` float(10,2) DEFAULT 0.00,
  `diaDos` float(10,2) DEFAULT 0.00,
  `diaTres` float(10,2) DEFAULT 0.00,
  `diaCuatro` float(10,2) DEFAULT 0.00,
  `diaCinco` float(10,2) DEFAULT 0.00,
  `pago` float(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `bolsas_toston`
--

INSERT INTO `bolsas_toston` (`id`, `id_planilla`, `id_embarque`, `fecha`, `diaUno`, `diaDos`, `diaTres`, `diaCuatro`, `diaCinco`, `pago`) VALUES
('1001', 6, 100, '2020-08-17', 3000.00, 0.00, 0.00, 0.00, 0.00, 3000.00),
('1011', 6, 101, '2020-08-18', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1012', 18, 101, '2020-08-18', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1013', 9, 101, '2020-08-18', 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00),
('1014', 11, 101, '2020-08-18', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1015', 15, 101, '2020-08-18', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1016', 12, 101, '2020-08-18', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1017', 14, 101, '2020-08-18', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1018', 13, 101, '2020-08-18', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1021', 6, 102, '2020-08-19', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1031', 6, 103, '2020-08-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1041', 6, 104, '2020-08-18', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1051', 6, 105, '2020-08-24', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1061', 6, 106, '2020-08-31', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1062', 19, 106, '2020-08-31', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1063', 11, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1064', 15, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1065', 18, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1066', 14, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1067', 20, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1068', 21, 106, '2020-08-31', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1069', 22, 106, '2020-08-31', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1071', 6, 107, '2020-09-07', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('10710', 24, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('10711', 23, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1072', 19, 107, '2020-09-07', 700.00, 0.00, 0.00, 0.00, 0.00, 700.00),
('1073', 11, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1074', 15, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1075', 18, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1076', 14, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1077', 20, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1078', 21, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1079', 12, 107, '2020-09-07', 450.00, 0.00, 0.00, 0.00, 0.00, 450.00),
('1081', 6, 108, '2020-10-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1091', 6, 109, '2020-09-14', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1101', 6, 110, '2020-09-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('11010', 25, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1102', 19, 110, '2020-09-21', 1200.00, 0.00, 0.00, 0.00, 0.00, 1200.00),
('1103', 11, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1104', 15, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1105', 14, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1106', 18, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1107', 21, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1108', 12, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1109', 26, 110, '2020-09-21', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1111', 6, 111, '2020-09-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1121', 6, 112, '2020-10-05', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1131', 6, 113, '2020-10-12', 1500.00, 500.00, 0.00, 0.00, 0.00, 2000.00),
('11310', 30, 113, '2020-10-12', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('11311', 28, 113, '2020-10-12', 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00),
('11312', 31, 113, '2020-10-12', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('11313', 32, 113, '2020-10-12', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('11314', 12, 113, '2020-10-12', 1600.00, 0.00, 0.00, 0.00, 0.00, 1600.00),
('1132', 19, 113, '2020-10-12', 2500.00, 0.00, 0.00, 0.00, 0.00, 2500.00),
('1133', 11, 113, '2020-10-12', 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00),
('1134', 15, 113, '2020-10-12', 1600.00, 0.00, 0.00, 0.00, 0.00, 1600.00),
('1135', 18, 113, '2020-10-12', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1136', 14, 113, '2020-10-12', 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00),
('1137', 26, 113, '2020-10-12', 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00),
('1138', 21, 113, '2020-10-12', 1600.00, 0.00, 0.00, 0.00, 0.00, 1600.00),
('1139', 29, 113, '2020-10-12', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1141', 6, 114, '2020-10-07', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('11410', 28, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1142', 19, 114, '2020-10-07', 1000.00, 0.00, 0.00, 0.00, 0.00, 1000.00),
('1143', 11, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1144', 15, 114, '2020-10-07', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1145', 18, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1146', 14, 114, '2020-10-07', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('1147', 21, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1148', 12, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1149', 27, 114, '2020-10-07', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1151', 6, 115, '2020-10-14', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1152', 19, 115, '2020-10-14', 700.00, 0.00, 0.00, 0.00, 0.00, 700.00),
('1153', 27, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('1154', 15, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('1155', 26, 115, '2020-10-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('1161', 6, 116, '2020-10-21', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1162', 19, 116, '2020-10-21', 500.00, 0.00, 0.00, 0.00, 0.00, 500.00),
('1163', 27, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1164', 15, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1165', 23, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1166', 14, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1167', 26, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1168', 12, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1169', 28, 116, '2020-10-21', 400.00, 0.00, 0.00, 0.00, 0.00, 400.00),
('1171', 6, 117, '2020-10-28', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1172', 19, 117, '2020-10-28', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('1173', 26, 117, '2020-10-28', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('1181', 6, 118, '2020-11-05', 0.00, 0.00, 1500.00, 0.00, 0.00, 1500.00),
('1191', 6, 119, '2020-11-18', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1201', 6, 120, '2020-12-04', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('1211', 6, 121, '2020-11-30', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('791', 6, 79, '2020-07-25', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('811', 6, 81, '2020-07-29', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('821', 6, 82, '2020-07-30', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('831', 6, 83, '2020-07-31', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('832', 9, 83, '2020-07-31', 700.00, 0.00, 0.00, 0.00, 0.00, 700.00),
('833', 10, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('834', 11, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('835', 12, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('836', 13, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('837', 14, 83, '2020-07-31', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('841', 9, 84, '2020-08-01', 700.00, 0.00, 0.00, 0.00, 0.00, 700.00),
('842', 15, 84, '2020-08-01', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('843', 11, 84, '2020-08-01', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('844', 12, 84, '2020-08-01', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('845', 6, 84, '2020-08-01', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('846', 14, 84, '2020-08-01', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('847', 16, 84, '2020-08-01', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('851', 6, 85, '2020-08-02', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('852', 9, 85, '2020-08-02', 1300.00, 0.00, 0.00, 0.00, 0.00, 1300.00),
('853', 15, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('854', 11, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('855', 12, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('856', 14, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('857', 13, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('858', 17, 85, '2020-08-02', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('861', 6, 86, '2020-08-03', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('862', 9, 86, '2020-08-03', 1050.00, 0.00, 0.00, 0.00, 0.00, 1050.00),
('863', 15, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('864', 11, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('865', 12, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('866', 18, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('867', 14, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('868', 13, 86, '2020-08-03', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('871', 6, 87, '2020-08-04', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('872', 9, 87, '2020-08-04', 1050.00, 0.00, 0.00, 0.00, 0.00, 1050.00),
('873', 15, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('874', 11, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('875', 12, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('876', 18, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('877', 14, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('878', 13, 87, '2020-08-04', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('881', 6, 88, '2020-08-05', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('882', 9, 88, '2020-08-05', 1300.00, 0.00, 0.00, 0.00, 0.00, 1300.00),
('883', 15, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('884', 11, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('885', 12, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('886', 18, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('887', 14, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('888', 13, 88, '2020-08-05', 600.00, 0.00, 0.00, 0.00, 0.00, 600.00),
('889', 19, 88, '2020-08-05', 800.00, 0.00, 0.00, 0.00, 0.00, 800.00),
('891', 6, 89, '2020-08-06', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('892', 12, 89, '2020-08-06', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('893', 13, 89, '2020-08-06', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('894', 14, 89, '2020-08-06', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('901', 6, 90, '2020-08-07', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('902', 12, 90, '2020-08-07', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('903', 14, 90, '2020-08-07', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('904', 13, 90, '2020-08-07', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('911', 6, 91, '2020-08-08', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('912', 12, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('913', 14, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('914', 13, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('915', 19, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('916', 15, 91, '2020-08-08', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('921', 12, 92, '2020-08-09', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('922', 6, 92, '2020-08-09', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('923', 13, 92, '2020-08-09', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('924', 14, 92, '2020-08-09', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('931', 12, 93, '2020-08-10', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('932', 6, 93, '2020-08-10', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('933', 14, 93, '2020-08-10', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('934', 13, 93, '2020-08-10', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('941', 12, 94, '2020-08-11', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('942', 6, 94, '2020-08-11', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('943', 13, 94, '2020-08-11', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('944', 14, 94, '2020-08-11', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('951', 6, 95, '2020-08-12', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('952', 12, 95, '2020-08-12', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('953', 13, 95, '2020-08-12', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('954', 14, 95, '2020-08-12', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('961', 6, 96, '2020-08-13', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('962', 13, 96, '2020-08-13', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('963', 12, 96, '2020-08-13', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('964', 14, 96, '2020-08-13', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('971', 6, 97, '2020-08-14', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('972', 12, 97, '2020-08-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('973', 13, 97, '2020-08-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('974', 14, 97, '2020-08-14', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('981', 6, 98, '2020-08-15', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('982', 12, 98, '2020-08-15', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('983', 13, 98, '2020-08-15', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('984', 14, 98, '2020-08-15', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('991', 6, 99, '2020-08-16', 1500.00, 0.00, 0.00, 0.00, 0.00, 1500.00),
('992', 12, 99, '2020-08-16', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('993', 13, 99, '2020-08-16', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00),
('994', 14, 99, '2020-08-16', 300.00, 0.00, 0.00, 0.00, 0.00, 300.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolseros`
--

DROP TABLE IF EXISTS `bolseros`;
CREATE TABLE `bolseros` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `Ap_p` varchar(200) NOT NULL,
  `Ap_m` varchar(255) NOT NULL,
  `edad` int(2) NOT NULL,
  `telefono` varchar(12) DEFAULT '',
  `direccion` varchar(100) NOT NULL,
  `no_cuenta` varchar(20) DEFAULT '',
  `Tipo` int(2) NOT NULL,
  `estado` int(2) DEFAULT 1,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolseros`
--

INSERT INTO `bolseros` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `estado`, `foto`) VALUES
(1, 'GERSON', 'RIVERA', 'ALVAREZ', 0, '', 'CUNDUACAN', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'BENY', 'CALDERON', 'AGUILAR', 0, '', 'EL CARMEN', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'NOE', 'RODRIGUEZ', 'GONZALEZ', 0, '', 'PLATANO Y CACAO 2DA', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'LUIS ARTURO', 'LICONA', 'RODRIGUEZ', 0, '', 'CUNDUACAN', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'JUAN ANTONIO', 'RODRIGUEZ', 'ROMERO', 0, '', 'CUNDUACAN', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'DANIEL ANTONIO', 'ENRRIQUE', 'DE LOS SANTOS', 0, '', 'MORELITOS', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(7, 'ELEAZAR', 'PEREZ', 'DIAZ', 0, '', 'CUMUAPA 1RA', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(8, 'MISAEL', 'SANCHEZ', 'MARTINEZ', 0, '', 'CUMUAPA 1RA', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'PEDRO', 'LOPEZ', 'MARTINEZ', 0, '', 'CUMUAPA 1RA', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'OSVALDO', 'PEREZ', 'MORALES', 0, '', 'CUMUAPA 1RA', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(11, 'NANCY', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(12, 'ESTELA', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(13, 'ENRRIQUE', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(14, 'AUDELIN', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(15, 'JOSE', 'ANTONIO', 'ARIAS', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(16, 'ALEX', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(17, 'MATEO', '', '', 0, '', '-', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(18, 'ADAN', '', '', 0, '', '#', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(19, 'CECILIA', '', '', 0, '', '#', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(20, 'MARCOS', '', '', 0, '', '#', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(21, 'FABIAN', '', '', 0, '', '#', '', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(22, 'ADRIAN', '', '', 0, '-', '-', '-', 2, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsero_extra`
--

DROP TABLE IF EXISTS `bolsero_extra`;
CREATE TABLE `bolsero_extra` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `nombre` varchar(50) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `apellidos` varchar(70) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `edad` int(3) NOT NULL,
  `telefono` varchar(15) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `direccion` varchar(70) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `cuenta` varchar(25) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `actividad` varchar(45) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `pago` float NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `fecha` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsero_extra`
--

INSERT INTO `bolsero_extra` (`id`, `nombre`, `apellidos`, `edad`, `telefono`, `direccion`, `cuenta`, `actividad`, `pago`, `id_embarque`, `fecha`) VALUES
('1091', 'JOSE ANTONIO', 'NO', 1, 'no', 'NO', 'NO', 'BOLSERO', 1500, 109, '2020-09-14'),
('1092', 'AUDELIN', 'NO', 1, 'no', 'NO', 'NO', 'BOLSERO', 900, 109, '2020-09-14'),
('1093', 'BRAYAN', 'NO', 1, 'no', 'NO', 'NO', 'BOLSERO', 300, 109, '2020-09-14'),
('1094', 'MARCOS', 'NO', 1, 'no', 'NO', 'NO', 'BOLSERO', 250, 109, '2020-09-14'),
('1095', 'ALEXIS ', 'NO', 1, 'no', 'NO', 'NO', 'BOLSERO', 300, 109, '2020-09-14'),
('1131', 'MARCOS', '-', 1, '', '-', '-', 'BOLSERO', 100, 113, '2020-10-12'),
('1132', 'LICONA', '-', 1, '', '-', '-', 'BOLSERO', 300, 113, '2020-10-12'),
('1133', 'MATEO', '-', 1, '', '-', '-', 'BOLSERO', 300, 113, '2020-10-12'),
('1134', 'ADRIAN', '-', 1, '', '-', '-', 'BOLSERO', 300, 113, '2020-10-12'),
('1141', 'LICONA', '-', 1, '', '-', '', 'BOLSERO', 600, 114, '2020-10-07'),
('1171', 'MACLIN', '-', 1, '', '-', '-', 'BOLSERO', 200, 117, '2020-10-28'),
('1172', 'ADRIAN', '-', 1, '-', '-', '-', 'BOLSERO', 200, 117, '2020-10-28'),
('771', 'JOSE ANTONIO', '-', 1, '', '-', '-', 'VELADOR', 1500, 77, '2020-07-25'),
('772', 'ANGEL', '-', 1, '', '-', '-', '-', 200, 77, '2020-07-25'),
('773', 'GUSTAVO', '-', 1, '', '-', '-', '-', 250, 77, '2020-07-25'),
('774', 'JAIME', '-', 1, '', '-', '-', '-', 250, 77, '2020-07-25'),
('775', 'SERGIO', '-', 1, '', '-', '-', '-', 200, 77, '2020-07-25'),
('776', 'WILLIAN', '-', 1, '', '-', '-', '-', 750, 77, '2020-07-25'),
('781', 'JOSE ANTONIO', '-', 1, '', '-', '-', 'VELADOR', 1500, 78, '2020-07-25'),
('782', 'GERARDO', '-', 1, '', '-', '-', '-', 900, 78, '2020-07-25'),
('783', 'ALDRICH', '-', 1, '', '-', '-', '-', 150, 78, '2020-07-25'),
('784', 'WILIAM', '-', 1, '', '-', '-', '-', 750, 78, '2020-07-25'),
('785', 'SERGIO', '-', 1, '', '-', '-', '-', 200, 78, '2020-07-25'),
('791', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 79, '2020-07-25'),
('792', 'NANCY', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 79, '2020-07-25'),
('793', 'ESTELA', 'BO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 79, '2020-07-25'),
('794', 'JUAN', 'NO', 1, '1', 'NIN', 'NI', 'BOLSERO', 70, 79, '2020-07-25'),
('795', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 79, '2020-07-25'),
('796', 'MARCOS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 80, 79, '2020-07-25'),
('797', 'SERGIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 80, 79, '2020-07-25'),
('798', 'WALTER', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 50, 79, '2020-07-25'),
('801', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 80, '2020-07-28'),
('802', 'NANCY', 'NO', 1, '1', 'NO', 'ON', 'BOLSERO', 600, 80, '2020-07-28'),
('803', 'ESTELA', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 80, '2020-07-28'),
('804', 'DEIBI', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 80, '2020-07-28'),
('805', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 600, 80, '2020-07-28'),
('806', 'SERGIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 380, 80, '2020-07-28'),
('811', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 81, '2020-07-29'),
('812', 'NANCY', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 81, '2020-07-29'),
('813', 'ESTELA', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 81, '2020-07-29'),
('814', 'ADRIAN', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 81, '2020-07-29'),
('815', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 81, '2020-07-29'),
('816', 'DEIBI', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 81, '2020-07-29'),
('817', 'SERGIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 81, '2020-07-29'),
('818', 'PEDRO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 81, '2020-07-29'),
('819', 'JESUS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 81, '2020-07-29'),
('821', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 82, '2020-07-30'),
('822', 'NANCY', '1', 1, 'no', 'NO', 'NO', 'BOLSERO', 600, 82, '2020-07-30'),
('823', 'ESTELA', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 82, '2020-07-30'),
('824', 'AUDELIN', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 82, '2020-07-30'),
('825', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 900, 82, '2020-07-30'),
('826', 'SERGIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 250, 82, '2020-07-30'),
('831', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 83, '2020-07-31'),
('8310', 'JESUS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 200, 83, '2020-07-31'),
('832', 'NANCY', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1150, 83, '2020-07-31'),
('833', 'ESTELA', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 400, 83, '2020-07-31'),
('834', 'AUDELIN', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 83, '2020-07-31'),
('835', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1150, 83, '2020-07-31'),
('836', 'SABDIEL', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 83, '2020-07-31'),
('837', 'MARCOS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 83, '2020-07-31'),
('838', 'ADAN', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 83, '2020-07-31'),
('839', 'MANUEL', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 100, 83, '2020-07-31'),
('841', 'JOSE ANTONO ', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 84, '2020-08-01'),
('842', 'NANCY', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1150, 84, '2020-08-01'),
('843', 'ESTELA', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 84, '2020-08-01'),
('844', 'GERARDO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1150, 84, '2020-08-01'),
('845', 'DEYBI', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 200, 84, '2020-08-01'),
('846', 'ALEXIS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 500, 84, '2020-08-01'),
('847', 'ISMAEL', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 250, 84, '2020-08-01'),
('848', 'ADRIAN', 'NI', 1, '1', 'NI', 'NI', 'BOLSERO', 100, 84, '2020-08-01'),
('849', 'ASUNCION', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 200, 84, '2020-08-01'),
('851', 'ASUNCION', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 400, 85, '2020-08-02'),
('852', 'JESUS', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 150, 85, '2020-08-02'),
('853', 'MISAEL', 'NO', 1, '1', 'N', 'N', 'BOLSERO', 550, 85, '2020-08-02'),
('854', 'ALEXIS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 85, '2020-08-02'),
('855', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 85, '2020-08-02'),
('856', 'ESTELA', 'N', 1, '1', 'NO', 'NO', 'BOLSERO', 300, 85, '2020-08-02'),
('857', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 85, '2020-08-02'),
('858', 'JOSE ANTONIO', 'N', 11, '1', 'NO', 'NO', 'BOLSERO', 1500, 85, '2020-08-02'),
('861', 'JOSE ANTONIO', 'NO', 1, '1', 'NO', 'NO', 'BOLSERO', 1500, 86, '2020-08-03'),
('862', 'NANCY', 'NO', 1, 'q', 'Q', 'NO', 'BOLSERO', 600, 86, '2020-08-03'),
('863', 'ESTELA', 'A', 1, '1', 'V', 'V', 'BOLSERO', 300, 86, '2020-08-03'),
('864', 'AUDELIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 550, 86, '2020-08-03'),
('865', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 86, '2020-08-03'),
('866', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 86, '2020-08-03'),
('867', 'ASUNCION', 'N', 1, '1', 'N', 'N', 'BOLSERO', 250, 86, '2020-08-03'),
('868', 'FRANKLIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 400, 86, '2020-08-03'),
('871', 'JOSE ANTONIO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1500, 87, '2020-08-04'),
('872', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 87, '2020-08-04'),
('873', 'ESTELA', 'N', 1, '1', 'N', 'N', 'BOLSERO', 300, 87, '2020-08-04'),
('874', 'AUDELIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 550, 87, '2020-08-04'),
('875', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 87, '2020-08-04'),
('876', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 87, '2020-08-04'),
('877', 'ASUNCION', 'N', 1, '1', 'N', 'N', 'BOLSERO', 250, 87, '2020-08-04'),
('878', 'FRANKLIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 400, 87, '2020-08-04'),
('881', 'JOSE ANTONIO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1500, 88, '2020-08-05'),
('882', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 88, '2020-08-05'),
('883', 'ESTELA', 'N', 1, '1', 'N', 'N', 'BOLSERO', 300, 88, '2020-08-05'),
('884', 'AUDELIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 300, 88, '2020-08-05'),
('885', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 88, '2020-08-05'),
('886', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 88, '2020-08-05'),
('887', 'ALEXIS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 88, '2020-08-05'),
('888', 'DIANA LIZBETH', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1200, 88, '2020-08-05'),
('891', 'JOSE ANTONIO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1500, 89, '2020-08-06'),
('892', 'JESUS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 100, 89, '2020-08-06'),
('893', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 89, '2020-08-06'),
('894', 'ESTELA', 'N', 1, '1', 'N', 'N', 'BOLSERO', 300, 89, '2020-08-06'),
('895', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1200, 89, '2020-08-06'),
('896', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 89, '2020-08-06'),
('897', 'ASUNCION', 'N', 1, '1', 'N', 'N', 'BOLSERO', 100, 89, '2020-08-06'),
('898', 'ALEXIS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 89, '2020-08-06'),
('899', 'DIANA LIZBETH', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1200, 89, '2020-08-06'),
('901', 'JOSE ANTONIO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1500, 90, '2020-08-07'),
('902', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 600, 90, '2020-08-07'),
('903', 'ESTELA', 'N', 1, '1', 'N', 'N', 'BOLSERO', 200, 90, '2020-08-07'),
('904', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1300, 90, '2020-08-07'),
('905', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 90, '2020-08-07'),
('906', 'ALEXIS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 90, '2020-08-07'),
('907', 'DIANA LIZBETH', 'N', 1, '1', 'N', 'N', 'BOLSERO', 800, 90, '2020-08-07'),
('911', 'JOSE ANTONIO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1500, 91, '2020-08-08'),
('912', 'AUDELIN', 'N', 1, '1', 'N', 'N', 'BOLSERO', 150, 91, '2020-08-08'),
('913', 'NANCY', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 91, '2020-08-08'),
('914', 'ESTELA', 'N', 1, '1', 'N', 'N', 'BOLSERO', 300, 91, '2020-08-08'),
('915', 'GERARDO', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 91, '2020-08-08'),
('916', 'JORGE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 91, '2020-08-08'),
('917', 'ALEXIS', 'N', 1, '1', 'N', 'N', 'BOLSERO', 900, 91, '2020-08-08'),
('918', 'DIANA LIZBETH', 'N', 1, '1', 'N', 'N', 'BOLSERO', 1000, 91, '2020-08-08'),
('919', 'ENRIQUE', 'N', 1, '1', 'N', 'N', 'BOLSERO', 100, 91, '2020-08-08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_bolsas`
--

DROP TABLE IF EXISTS `cuenta_bolsas`;
CREATE TABLE `cuenta_bolsas` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `idemb` int(11) DEFAULT NULL,
  `ingreso` double(10,2) DEFAULT 0.00,
  `egreso` double(10,2) DEFAULT 0.00,
  `saldo` double(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `cuenta_bolsas`
--

INSERT INTO `cuenta_bolsas` (`id`, `idemb`, `ingreso`, `egreso`, `saldo`) VALUES
('1001', 100, 0.00, 0.00, 1552.83),
('1011', 101, 0.00, 0.00, 1552.83),
('1021', 102, 0.00, 0.00, 1552.83),
('1031', 103, 0.00, 0.00, 1552.83),
('1041', 104, 0.00, 0.00, 1552.83),
('1051', 105, 0.00, 0.00, 1552.83),
('1061', 106, 0.00, 0.00, 1552.83),
('1071', 107, 0.00, 0.00, 1552.83),
('1081', 108, 0.00, 0.00, 1552.83),
('1091', 109, 0.00, 0.00, 1552.83),
('1101', 110, 0.00, 0.00, 1552.83),
('1111', 111, 0.00, 0.00, 1552.83),
('1121', 112, 0.00, 0.00, 1552.83),
('1131', 113, 0.00, 0.00, 1552.83),
('1141', 114, 0.00, 0.00, 1552.83),
('1151', 115, 0.00, 0.00, 1552.83),
('1161', 116, 0.00, 0.00, 1552.83),
('1171', 117, 1000.00, 0.00, 2552.83),
('1181', 118, 0.00, 0.00, 2552.83),
('1191', 119, 0.00, 0.00, 2552.83),
('1201', 120, 0.00, 0.00, 2552.83),
('1211', 121, 0.00, 0.00, 2552.83),
('1221', 122, 0.00, 0.00, 2552.83),
('761', 76, 0.00, 0.00, 222.17),
('771', 77, 498.50, 88.20, 632.47),
('772', 78, 0.00, 87.00, 545.47),
('782', 79, 0.00, 85.90, 459.57),
('792', 80, 0.00, 82.00, 377.57),
('802', 81, 0.00, 63.00, 314.57),
('812', 82, 0.00, 83.00, 231.57),
('831', 83, 0.00, 86.00, 145.57),
('841', 84, 0.00, 88.00, 57.57),
('851', 85, 0.00, 84.30, 570.70),
('861', 86, 0.00, 93.00, 477.70),
('871', 87, 0.00, 93.00, 477.70),
('881', 88, 0.00, 111.00, 263.25),
('891', 89, 0.00, 82.00, 181.25),
('901', 90, 0.00, 82.00, 181.25),
('911', 91, 1496.70, 84.87, 1593.08),
('921', 92, 0.00, 84.87, 1552.83),
('931', 93, 0.00, 0.00, 1552.83),
('941', 94, 0.00, 0.00, 1552.83),
('951', 95, 0.00, 0.00, 1552.83),
('961', 96, 0.00, 0.00, 1552.83),
('971', 97, 0.00, 0.00, 1552.83),
('981', 98, 0.00, 0.00, 1552.83),
('991', 99, 0.00, 0.00, 1552.83);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_dolares`
--

DROP TABLE IF EXISTS `cuenta_dolares`;
CREATE TABLE `cuenta_dolares` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_emb` int(11) DEFAULT NULL,
  `total_ingreso` double(10,2) DEFAULT 0.00,
  `total_egreso` double(10,2) DEFAULT 0.00,
  `total_saldo` double(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `cuenta_dolares`
--

INSERT INTO `cuenta_dolares` (`id`, `id_emb`, `total_ingreso`, `total_egreso`, `total_saldo`) VALUES
('1001', 100, 0.00, 20000.00, 6086.91),
('1011', 101, 13872.01, 10000.00, 9958.92),
('1021', 102, 13910.66, 11000.00, 12869.58),
('1031', 103, 14861.12, 12000.00, 15730.70),
('1041', 104, 18024.19, 12000.00, 21754.89),
('1051', 105, 14828.51, 14000.00, 22583.40),
('1061', 106, 10000.00, 13000.00, 19583.40),
('1071', 107, 13456.94, 12000.00, 21040.34),
('1081', 108, 14882.82, 13000.00, 22923.16),
('1091', 109, 16552.95, 15000.00, 24476.11),
('1101', 110, 16515.08, 29000.00, 11991.19),
('1111', 111, 14681.01, 0.00, 26672.20),
('1121', 112, 14157.56, 28000.00, 12829.76),
('1131', 113, 15964.56, 15000.00, 13794.32),
('1141', 114, 13538.66, 14000.00, 13332.98),
('1151', 115, 14845.38, 15000.00, 13178.36),
('1161', 116, 18919.15, 18000.00, 14097.51),
('1171', 117, 15458.19, 16000.00, 13555.70),
('1181', 118, 14722.86, 18000.00, 10278.56),
('1191', 119, 19589.00, 16000.00, 13867.56),
('1201', 120, 14202.68, 14000.00, 14070.24),
('1211', 121, 13463.64, 14000.00, 13533.88),
('1221', 122, 0.00, 0.00, 13533.88),
('761', 76, 0.00, 0.00, 15088.50),
('771', 77, 18060.40, 14523.20, 18625.70),
('781', 78, 0.00, 13500.00, 5125.70),
('791', 79, 24000.00, 19023.21, 10102.49),
('801', 80, 13840.52, 23843.00, 100.01),
('811', 81, 0.00, 0.00, 100.01),
('821', 82, 18594.60, 15000.00, 3694.61),
('831', 83, 12000.00, 14000.00, 1694.61),
('841', 84, 12000.00, 12000.00, 194.61),
('851', 85, 14161.90, 14000.00, 356.51),
('861', 86, 14632.98, 14000.00, 989.49),
('871', 87, 14632.98, 14000.00, 989.49),
('881', 88, 12000.00, 12000.00, 1787.83),
('891', 89, 17173.46, 11000.00, 7961.29),
('901', 90, 17173.46, 11000.00, 7961.29),
('911', 91, 23959.03, 15000.00, 15920.32),
('921', 92, 15100.75, 13000.00, 18021.07),
('931', 93, 14416.83, 12000.00, 20437.90),
('941', 94, 14651.82, 12000.00, 23089.72),
('951', 95, 14474.81, 13000.00, 24564.53),
('961', 96, 12316.02, 13000.00, 23880.55),
('971', 97, 14388.06, 14023.20, 24245.41),
('981', 98, 14772.46, 13723.20, 25294.67),
('991', 99, 13792.24, 13000.00, 26086.91);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_pesos`
--

DROP TABLE IF EXISTS `cuenta_pesos`;
CREATE TABLE `cuenta_pesos` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_emb` int(11) DEFAULT NULL,
  `total_ingreso` double(10,2) DEFAULT 0.00,
  `total_egreso` double(10,2) DEFAULT 0.00,
  `total_saldo` double(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `cuenta_pesos`
--

INSERT INTO `cuenta_pesos` (`id`, `id_emb`, `total_ingreso`, `total_egreso`, `total_saldo`) VALUES
('1001', 100, 457470.02, 426033.00, 191168.41),
('1011', 101, 228026.01, 356434.40, 62760.02),
('1021', 102, 244889.69, 265708.40, 41941.31),
('1031', 103, 267740.41, 255053.70, 54628.02),
('1041', 104, 263589.59, 306543.76, 11673.85),
('1051', 105, 315817.40, 310658.36, 16832.89),
('1061', 106, 289684.19, 305669.02, 848.06),
('1071', 107, 265004.39, 276519.10, -10666.65),
('1081', 108, 285826.99, 266389.92, 8770.42),
('1091', 109, 327673.64, 335874.80, 569.26),
('1101', 110, 619556.72, 262813.65, 357312.33),
('1111', 111, 0.00, 277279.40, 80032.93),
('1121', 112, 613925.19, 298644.80, 395313.32),
('1131', 113, 331432.51, 337269.00, 389476.83),
('1141', 114, 300399.40, 269804.53, 420071.70),
('1151', 115, 319466.77, 269052.80, 470485.67),
('1161', 116, 378143.99, 398133.49, 450496.17),
('1171', 117, 337160.00, 350850.28, 436805.89),
('1181', 118, 376599.59, 457358.80, 356046.68),
('1191', 119, 323041.60, 303445.44, 375642.84),
('1201', 120, 280138.59, 261786.45, 393994.98),
('1211', 121, 281156.01, 288208.10, 386942.89),
('761', 76, 0.00, 0.00, 11240.38),
('771', 77, 270607.69, 278975.70, 2872.37),
('781', 78, 255491.99, 255276.70, 3087.66),
('791', 79, 352753.50, 355764.66, 76.53),
('801', 80, 443692.86, 227790.81, 216418.58),
('811', 81, 0.00, 202766.10, 13651.90),
('821', 82, 281717.41, 288411.10, 6958.21),
('831', 83, 273386.41, 303622.29, -23277.68),
('841', 84, 233872.81, 255261.40, -15667.70),
('851', 85, 296997.40, 273311.00, 8018.70),
('861', 86, 332738.00, 297421.20, 43335.50),
('871', 87, 332738.00, 267772.09, 72984.61),
('881', 88, 294176.40, 339039.59, 172362.99),
('891', 89, 262281.80, 291485.94, 143158.85),
('901', 90, 262281.80, 279497.23, 155147.56),
('911', 91, 367644.00, 410467.37, 104617.23),
('921', 92, 321561.50, 259085.31, 167093.42),
('931', 93, 285265.21, 310730.80, 141627.83),
('941', 94, 288022.80, 298047.50, 131603.13),
('951', 95, 302841.50, 291813.96, 142630.67),
('961', 96, 289819.40, 288645.25, 143804.82),
('971', 97, 303109.79, 399638.80, 47275.82),
('981', 98, 299669.68, 198342.00, 148603.50),
('991', 99, 292281.60, 259153.70, 181731.40);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dolares`
--

DROP TABLE IF EXISTS `dolares`;
CREATE TABLE `dolares` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_cuentaD` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `concepto` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `ingreso` double(10,2) DEFAULT 0.00,
  `egreso` double(10,2) DEFAULT 0.00,
  `saldo` double(10,2) NOT NULL,
  `taza_cambio` double(10,4) DEFAULT 0.0000,
  `activo` int(2) DEFAULT 0,
  `mostrar` int(2) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `dolares`
--

INSERT INTO `dolares` (`id`, `id_cuentaD`, `concepto`, `ingreso`, `egreso`, `saldo`, `taza_cambio`, `activo`, `mostrar`) VALUES
('1001', '1001', 'SALDO ANTERIOR', 0.00, 0.00, 26086.91, 0.0000, 0, 1),
('1002', '1001', 'CAMBIO E100', 0.00, 10000.00, 16086.91, 22.6958, 1, 1),
('1003', '1001', 'CAMBIO E100', 0.00, 10000.00, 6086.91, 23.0512, 1, 1),
('1011', '1011', 'SALDO ANTERIOR', 0.00, 0.00, 6086.91, 0.0000, 0, 1),
('1012', '1011', 'TRANSFERENCIA', 13872.01, 0.00, 19958.92, 0.0000, 1, 1),
('1013', '1011', 'CAMBIO E101', 0.00, 10000.00, 9958.92, 22.8026, 1, 1),
('1021', '1021', 'SALDO ANTERIOR', 0.00, 0.00, 9958.92, 0.0000, 0, 1),
('1022', '1021', 'TRANSFERENCIA', 13910.66, 0.00, 23869.58, 0.0000, 1, 1),
('1023', '1021', 'CAMBIO E102', 0.00, 11000.00, 12869.58, 22.2627, 1, 1),
('1031', '1031', 'SALDO ANTERIOR', 0.00, 0.00, 12869.58, 0.0000, 0, 1),
('1032', '1031', 'TRANSFERENCIA', 14861.12, 0.00, 27730.70, 0.0000, 1, 1),
('1033', '1031', 'CAMBIO 103', 0.00, 12000.00, 15730.70, 22.3117, 1, 1),
('1041', '1041', 'SALDO ANTERIOR', 0.00, 0.00, 15730.70, 0.0000, 0, 1),
('1042', '1041', 'TRANSFERENCIA', 18024.19, 0.00, 33754.89, 0.0000, 1, 1),
('1043', '1041', 'CAMBIO E104', 0.00, 12000.00, 21754.89, 21.9658, 1, 1),
('1051', '1051', 'SALDO ANTERIOR', 0.00, 0.00, 21754.89, 0.0000, 0, 1),
('1052', '1051', 'TRANSFERENCIA', 14828.51, 0.00, 36583.40, 0.0000, 1, 1),
('1053', '1051', 'CAMBIO E105', 0.00, 13000.00, 23583.40, 22.5464, 1, 1),
('1054', '1051', 'CAMBIO E105', 0.00, 1000.00, 22583.40, 22.7142, 1, 1),
('1061', '1061', 'SALDO ANTERIOR', 0.00, 0.00, 22583.40, 0.0000, 0, 1),
('1062', '1061', 'TRANSFERENCIA', 10000.00, 0.00, 32583.40, 0.0000, 1, 1),
('1063', '1061', 'CAMBIO E106', 0.00, 13000.00, 19583.40, 22.2834, 1, 1),
('1071', '1071', 'SALDO ANTERIOR', 0.00, 0.00, 19583.40, 0.0000, 0, 1),
('1072', '1071', 'TRANSFERENCIA', 13456.94, 0.00, 33040.34, 0.0000, 1, 1),
('1073', '1071', 'CAMBIO 107', 0.00, 6000.00, 27040.34, 22.1419, 1, 1),
('1074', '1071', 'CAMBIO E107', 0.00, 6000.00, 21040.34, 22.0255, 1, 1),
('1081', '1081', 'SALDO ANTERIOR', 0.00, 0.00, 21040.34, 0.0000, 0, 1),
('1082', '1081', 'TRANSFERENCIA', 14882.82, 0.00, 35923.16, 0.0000, 1, 1),
('1083', '1081', 'CAMBIO', 0.00, 6000.00, 29923.16, 22.0204, 1, 1),
('1084', '1081', 'CAMBIO E108', 0.00, 7000.00, 22923.16, 21.9578, 1, 1),
('1091', '1091', 'SALDO ANTERIOR', 0.00, 0.00, 22923.16, 0.0000, 0, 1),
('1092', '1091', 'TRANSFERENCIA', 16552.95, 0.00, 39476.11, 0.0000, 1, 1),
('1093', '1091', 'CAMBIO E109', 0.00, 13500.00, 25976.11, 21.8828, 1, 1),
('1094', '1091', 'CAMBIO E109', 0.00, 1500.00, 24476.11, 21.5039, 1, 1),
('1101', '1101', 'SALDO ANTERIOR', 0.00, 0.00, 24476.11, 0.0000, 0, 1),
('1102', '1101', 'TRANSFERENCIA', 16515.08, 0.00, 40991.19, 0.0000, 1, 1),
('1103', '1101', 'CAMBIO E110', 0.00, 10000.00, 30991.19, 21.5561, 1, 1),
('1104', '1101', 'CAMBIO E110', 0.00, 5000.00, 25991.19, 21.4803, 1, 1),
('1105', '1101', 'CAMBIO E110', 0.00, 14000.00, 11991.19, 21.1853, 1, 1),
('1111', '1111', 'SALDO ANTERIOR', 0.00, 0.00, 11991.19, 0.0000, 0, 1),
('1112', '1111', 'TRANSFERENCIA', 14681.01, 0.00, 26672.20, 0.0000, 1, 1),
('1121', '1121', 'SALDO ANTERIOR', 0.00, 0.00, 26672.20, 0.0000, 0, 1),
('1122', '1121', 'TRANSFERENCIA', 14157.56, 0.00, 40829.76, 0.0000, 1, 1),
('1123', '1121', 'CAMBIO E112', 0.00, 10000.00, 30829.76, 22.5895, 1, 1),
('1124', '1121', 'CAMBIO E112', 0.00, 4000.00, 26829.76, 22.0967, 1, 1),
('1125', '1121', 'CAMBIO E112', 0.00, 14000.00, 12829.76, 21.4031, 1, 1),
('1131', '1131', 'SALDO ANTERIOR', 0.00, 0.00, 12829.76, 0.0000, 0, 1),
('1132', '1131', 'TRANSFERENCIA', 15964.56, 0.00, 28794.32, 0.0000, 1, 1),
('1133', '1131', 'CAMBIO E113', 0.00, 15000.00, 13794.32, 22.0955, 1, 1),
('1141', '1141', 'SALDO ANTERIOR', 0.00, 0.00, 13794.32, 0.0000, 0, 1),
('1142', '1141', 'TRANSFERENCIA', 13538.66, 0.00, 27332.98, 0.0000, 1, 1),
('1143', '1141', 'CAMBIO E114', 0.00, 14000.00, 13332.98, 21.4571, 1, 1),
('1151', '1151', 'SALDO ANTERIOR', 0.00, 0.00, 13332.98, 0.0000, 0, 1),
('1152', '1151', 'TRANSFERENCIA', 14845.38, 0.00, 28178.36, 0.0000, 1, 1),
('1153', '1151', 'CAMBIO 1', 0.00, 12000.00, 16178.36, 21.3089, 1, 1),
('1154', '1151', 'CAMBIO 2', 0.00, 3000.00, 13178.36, 21.2533, 1, 1),
('1161', '1161', 'SALDO ANTERIOR', 0.00, 0.00, 13178.36, 0.0000, 0, 1),
('1162', '1161', 'TRANSFERENCIA', 18919.15, 0.00, 32097.51, 0.0000, 1, 1),
('1163', '1161', 'CAMBIO 1', 0.00, 18000.00, 14097.51, 21.0080, 1, 1),
('1171', '1171', 'SALDO ANTERIOR', 0.00, 0.00, 14097.51, 0.0000, 0, 1),
('1172', '1171', 'TRANSFERENCIA', 15458.19, 0.00, 29555.70, 0.0000, 1, 1),
('1173', '1171', 'CAMBIO E117', 0.00, 16000.00, 13555.70, 21.0725, 1, 1),
('1181', '1181', 'SALDO ANTERIOR', 0.00, 0.00, 13555.70, 0.0000, 0, 1),
('1182', '1181', 'TRANFERENCIA', 14722.86, 0.00, 28278.56, 0.0000, 1, 1),
('1183', '1181', 'CAMBIO 1', 0.00, 18000.00, 10278.56, 20.9222, 1, 1),
('1191', '1191', 'SALDO ANTERIOR', 0.00, 0.00, 10278.56, 0.0000, 0, 1),
('1192', '1191', 'TRANSFERENCIA', 19589.00, 0.00, 29867.56, 0.0000, 1, 1),
('1193', '1191', 'CAMBIO 1', 0.00, 16000.00, 13867.56, 20.1901, 1, 1),
('1201', '1201', 'SALDO ANTERIOR', 0.00, 0.00, 13867.56, 0.0000, 0, 1),
('1202', '1201', 'TRANSFERENCIA', 14202.68, 0.00, 28070.24, 0.0000, 1, 1),
('1203', '1201', 'CAMBIO E120', 0.00, 14000.00, 14070.24, 20.0099, 1, 1),
('1211', '1211', 'SALDO ANTERIOR', 0.00, 0.00, 14070.24, 0.0000, 0, 1),
('1212', '1211', 'TRANSFERENCIA', 13463.64, 0.00, 27533.88, 0.0000, 1, 1),
('1213', '1211', 'CAMBIO E121', 0.00, 10000.00, 17533.88, 20.1170, 1, 1),
('1214', '1211', 'CAMBIO 2 E121', 0.00, 4000.00, 13533.88, 19.9965, 1, 1),
('1221', '1221', 'SALDO ANTERIOR', 0.00, 0.00, 13533.88, 0.0000, 0, 1),
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 141088.50, 0.0000, 0, 1),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 141088.50, 0.0000, 0, 1),
('772', '771', 'TRANSFERENCIA', 18060.40, 0.00, 159148.90, 0.0000, 1, 1),
('773', '771', 'CAMBIO E77', 0.00, 14500.00, 144648.90, 18.6626, 1, 1),
('774', '771', 'COMISION BANCO', 0.00, 23.20, 144625.70, 0.0000, 1, 1),
('781', '781', 'SALDO ANTERIOR', 0.00, 0.00, 144625.70, 0.0000, 0, 1),
('782', '781', 'CAMBIO E78', 0.00, 13500.00, 131125.70, 18.8480, 1, 1),
('791', '791', 'SALDO ANTERIOR', 0.00, 0.00, 131125.70, 0.0000, 0, 1),
('792', '791', 'TRANSFERENCIA', 24000.00, 0.00, 155125.70, 0.0000, 1, 1),
('793', '791', 'CAMBIO E79', 0.00, 1000.00, 154125.70, 18.6339, 1, 1),
('794', '791', 'COM ANUALIDAD BANCO', 0.00, 0.01, 154125.69, 0.0000, 1, 1),
('795', '791', 'CAMBIO E79', 0.00, 18000.00, 136125.69, 18.5622, 1, 1),
('796', '791', 'COM TRANS BANCO', 0.00, 23.20, 136102.49, 0.0000, 1, 1),
('801', '801', 'SALDO ANTERIOR', 0.00, 0.00, 136102.49, 0.0000, 0, 1),
('802', '801', 'TRANSFERENCIA', 13840.52, 0.00, 149943.01, 0.0000, 1, 1),
('803', '801', 'CAMBIO E80', 0.00, 1000.00, 148943.01, 18.7194, 1, 1),
('804', '801', 'CAMBIO E80', 0.00, 22843.00, 126100.01, 18.6041, 1, 1),
('811', '811', 'SALDO ANTERIOR', 0.00, 0.00, 126100.01, 0.0000, 0, 1),
('812', '821', 'SALDO ANTERIOR', 0.00, 0.00, 126100.01, 0.0000, 0, 1),
('822', '821', 'TRANSFERENCIA', 18594.60, 0.00, 144694.61, 0.0000, 1, 1),
('823', '821', 'CAMBIO E82', 0.00, 13500.00, 131194.61, 18.7637, 1, 1),
('824', '821', 'CAMBIO E82', 0.00, 1500.00, 129694.61, 18.9383, 1, 1),
('831', '831', 'SALDO ANTERIOR', 0.00, 0.00, 129694.61, 0.0000, 0, 1),
('832', '831', 'TRANSFERENCIA', 12000.00, 0.00, 141694.61, 0.0000, 1, 1),
('833', '831', 'CAMBIO E83', 0.00, 3000.00, 138694.61, 18.9732, 1, 1),
('834', '831', 'CAMBIO E83', 0.00, 11000.00, 127694.61, 19.6788, 1, 1),
('841', '841', 'SALDO ANTERIOR', 0.00, 0.00, 126194.61, 0.0000, 0, 1),
('842', '841', 'TRANSFERENCIA', 12000.00, 0.00, 138194.61, 0.0000, 1, 1),
('843', '841', 'CAMBIO E84', 0.00, 12000.00, 126194.61, 19.4894, 1, 1),
('851', '851', 'SALDO ANTERIOR', 0.00, 0.00, 126194.61, 0.0000, 0, 1),
('852', '851', 'TRANSFERENCIA', 14161.90, 0.00, 140356.51, 0.0000, 1, 1),
('853', '851', 'CAMBIO E85', 0.00, 14000.00, 126356.51, 21.2141, 1, 1),
('861', '861', 'SALDO ANTERIOR', 0.00, 0.00, 126356.51, 0.0000, 0, 1),
('862', '861', 'TRANSFERENCIA', 14632.98, 0.00, 140989.49, 0.0000, 1, 1),
('863', '861', 'CAMBIO E886', 0.00, 14000.00, 126989.49, 23.7670, 1, 1),
('871', '871', 'SALDO ANTERIOR', 0.00, 0.00, 126356.51, 0.0000, 0, 1),
('872', '871', 'TRANSFERENCIA', 14632.98, 0.00, 140989.49, 0.0000, 1, 1),
('873', '871', '', 0.00, 0.00, 126000.00, 0.0000, 0, 0),
('874', '871', 'CAMBIO E886', 0.00, 14000.00, 126989.49, 23.7670, 1, 1),
('881', '881', 'SALDO ANTERIOR', 0.00, 0.00, 127787.83, 0.0000, 0, 1),
('882', '881', 'TRANSFERENCIA', 12000.00, 0.00, 139787.83, 0.0000, 1, 1),
('883', '881', 'CAMBIO UNO', 0.00, 12000.00, 127787.83, 24.5147, 1, 1),
('891', '891', 'SALDO ANTERIOR', 0.00, 0.00, 127787.83, 0.0000, 0, 1),
('892', '891', 'TRANSFERENCIA', 17173.46, 0.00, 144961.29, 0.0000, 1, 1),
('893', '891', 'CAMBIO UNO', 0.00, 11000.00, 133961.29, 23.8438, 1, 1),
('901', '901', 'SALDO ANTERIOR', 0.00, 0.00, 127787.83, 0.0000, 0, 1),
('902', '901', 'TRANSFERENCIA', 17173.46, 0.00, 144961.29, 0.0000, 1, 1),
('903', '901', 'CAMBIO UNO', 0.00, 11000.00, 133961.29, 23.8438, 1, 1),
('911', '911', 'SALDO ANTERIOR', 0.00, 0.00, 132961.29, 0.0000, 0, 1),
('912', '911', 'TRANSFERENCIA', 23959.03, 0.00, 156920.32, 0.0000, 1, 1),
('913', '911', 'CAMBIO UNO', 0.00, 15000.00, 141920.32, 24.5096, 1, 1),
('921', '921', 'SALDO ANTERIOR', 0.00, 0.00, 141920.32, 0.0000, 0, 1),
('922', '921', 'CAMBIO ', 0.00, 13000.00, 128920.32, 24.7355, 1, 1),
('923', '921', 'TRANSFERENCIA', 15100.75, 0.00, 144021.07, 0.0000, 1, 1),
('931', '931', 'SALDO ANTERIOR', 0.00, 0.00, 144021.07, 0.0000, 0, 1),
('932', '931', 'TRANSFERENCIA', 14416.83, 0.00, 158437.90, 0.0000, 1, 1),
('933', '931', 'CAMBIO', 0.00, 12000.00, 146437.90, 23.7721, 1, 1),
('941', '941', 'SALDO ANTERIOR', 0.00, 0.00, 146437.90, 0.0000, 0, 1),
('942', '941', 'TRANSFERENCIA', 14651.82, 0.00, 161089.72, 0.0000, 1, 1),
('943', '941', 'CAMBIO', 0.00, 12000.00, 149089.72, 24.0019, 1, 1),
('951', '951', 'SALDO ANTERIOR', 0.00, 0.00, 149089.72, 0.0000, 0, 1),
('952', '951', 'TRANSFERENCIA', 14474.81, 0.00, 163564.53, 0.0000, 1, 1),
('953', '951', 'CAMBIO', 0.00, 13000.00, 150564.53, 23.2955, 1, 1),
('961', '961', 'SALDO ANTERIOR', 0.00, 0.00, 150564.53, 0.0000, 0, 1),
('962', '961', 'TRANSFERENCIA', 12316.02, 0.00, 162880.55, 0.0000, 1, 1),
('963', '961', 'CAMBIO E96', 0.00, 13000.00, 149880.55, 22.2938, 1, 1),
('971', '971', 'SALDO ANTERIOR', 0.00, 0.00, 149880.55, 0.0000, 0, 1),
('972', '971', 'TRANSFERENCIA', 14388.06, 0.00, 164268.61, 0.0000, 1, 1),
('973', '971', 'CAMBIO E97', 0.00, 14000.00, 150268.61, 21.6507, 1, 1),
('974', '971', 'COMISION', 0.00, 23.20, 150245.41, 0.0000, 1, 1),
('981', '981', 'SALDO ANTERIOR', 0.00, 0.00, 150245.41, 0.0000, 0, 1),
('982', '981', 'TRANSFERENCIA', 14772.46, 0.00, 165017.87, 0.0000, 1, 1),
('983', '981', 'CAMBIO E98', 0.00, 13700.00, 151317.87, 21.8737, 1, 1),
('984', '981', 'COMISION', 0.00, 23.20, 151294.67, 0.0000, 1, 1),
('991', '991', 'SALDO ANTERIOR', 0.00, 0.00, 151294.67, 0.0000, 0, 1),
('992', '991', 'TRANSFERENCIA', 13792.24, 0.00, 165086.91, 0.0000, 1, 1),
('993', '991', 'CAMBIO E99', 0.00, 13000.00, 152086.91, 22.4832, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `embarque`
--

DROP TABLE IF EXISTS `embarque`;
CREATE TABLE `embarque` (
  `id` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `dia_actual` int(2) NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `cant_bolsas_embarque` int(10) DEFAULT NULL,
  `toneladas` float DEFAULT 0,
  `contenedor` varchar(20) DEFAULT NULL,
  `no_sello` varchar(10) DEFAULT NULL,
  `cuentas` int(2) DEFAULT 0,
  `matricula` varchar(25) DEFAULT NULL,
  `temperatura` varchar(5) DEFAULT '0',
  `nombre_conductor` varchar(100) DEFAULT NULL,
  `perdida` int(5) DEFAULT 0,
  `bolsas_exitentes` int(11) DEFAULT 0,
  `bolsas_toston` int(11) DEFAULT 0,
  `total_gastos` float(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `embarque`
--

INSERT INTO `embarque` (`id`, `fecha_inicio`, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, `toneladas`, `contenedor`, `no_sello`, `cuentas`, `matricula`, `temperatura`, `nombre_conductor`, `perdida`, `bolsas_exitentes`, `bolsas_toston`, `total_gastos`) VALUES
(77, '2020-07-25', 0, '2020-07-25', 921, 47.1904, '-', '-', 1, '-', '0', '-', 0, 921, 0, 278975.69),
(78, '2020-07-25', 0, '2020-07-25', 898, 47.5172, '-', '-', 1, '-', '0', '-', 0, 898, 0, 255276.69),
(79, '2020-07-25', 0, '2020-07-25', 895, 45.9374, '-', '-', 1, '-', '0', '-', 0, 895, 0, 355764.66),
(80, '2020-07-28', 0, '2020-07-28', 848, 42.7492, '-', '-', 1, '-', '0', '-', 0, 837, 0, 227790.81),
(81, '2020-07-29', 0, '2020-07-29', 717, 39.4848, '-', '-', 1, '-', '0', '-', 0, 706, 0, 202766.09),
(82, '2020-07-30', 0, '2020-07-30', 956, 48.6841, '-', '-', 1, '-', '0', '-', 0, 956, 0, 288411.09),
(83, '2020-07-31', 0, '2020-07-31', 936, 48.3064, '-', '-', 1, '-', '0', '-', 0, 936, 0, 302578.28),
(84, '2020-08-01', 0, '2020-08-01', 967, 49.2496, '-', '-', 1, '-', '0', '-', 0, 967, 0, 255261.41),
(85, '2020-08-02', 0, '2020-08-02', 870, 42.4487, '-', '-', 1, '-', '0', '-', 0, 862, 0, 273311.00),
(86, '2020-08-03', 0, '2020-08-03', 954, 46.4042, '-', '-', 1, '-', '0', '-', 0, 889, 0, 297421.19),
(87, '2020-08-04', 0, '2020-08-04', 954, 43.9966, '-', '-', 1, '-', '0', '-', 0, 889, 0, 267772.09),
(88, '2020-08-05', 0, '2020-08-05', 1001, 49.2504, '-', '-', 1, '-', '0', '-', 0, 909, 0, 337995.59),
(89, '2020-08-06', 0, '2020-08-06', 950, 46.8402, '-', '-', 1, '-', '0', '-', 0, 947, 0, 291485.94),
(90, '2020-08-07', 0, '2020-08-07', 970, 47.7974, '-', '-', 1, '-', '0', '-', 0, 947, 0, 279497.22),
(91, '2020-08-08', 0, '2020-08-08', 977, 48.7806, '-', '-', 1, '-', '0', '-', 0, 970, 0, 410467.38),
(92, '2020-08-09', 0, '2020-08-09', 996, 48.7784, '-', '-', 1, '-', '0', '-', 0, 970, 0, 259085.31),
(93, '2020-08-10', 0, '2020-08-10', 844, 41.3263, '-', '-', 1, '-', '0', '-', 0, 970, 0, 310730.81),
(94, '2020-08-11', 0, '2020-08-11', 968, 47.4732, '-', '-', 1, '-', '0', '-', 0, 970, 0, 297003.53),
(95, '2020-08-12', 0, '2020-08-12', 993, 47.4994, '-', '-', 1, '-', '0', '-', 0, 970, 0, 291813.94),
(96, '2020-08-13', 0, '2020-08-13', 954, 45.4982, '-', '-', 1, '-', '0', '-', 0, 970, 0, 288645.25),
(97, '2020-08-14', 0, '2020-08-14', 958, 46.6862, '-', '-', 1, '-', '0', '-', 0, 970, 0, 398594.84),
(98, '2020-08-15', 0, '2020-08-15', 765, 36.892, '-', '-', 1, '.', '0', '-', 0, 970, 0, 198341.98),
(99, '2020-08-16', 0, '2020-08-16', 941, 45.5876, '-', '-', 1, '-', '0', '-', 0, 970, 0, 259153.70),
(100, '2020-08-17', 0, '2020-08-17', 1000, 46.8099, '-', '-', 1, '-', '0', '-', 0, 970, 0, 424988.97),
(101, '2020-08-18', 0, '2020-08-18', 945, 45.1976, '-', '-', 1, '-', '0', '-', 0, 970, 0, 356434.41),
(102, '2020-08-19', 0, '2020-08-19', 956, 47.6176, '-', '-', 1, ' -', '0', '-', 0, 970, 0, 265708.41),
(103, '2020-08-20', 0, '2020-08-20', 979, 47.7753, '-', '-', 1, '-', '0', '-', 0, 970, 0, 255053.70),
(104, '2020-08-21', 0, '2020-08-21', 987, 47.4633, '-', '-', 1, '-', '0', '-', 0, 970, 0, 306253.78),
(105, '2020-08-24', 0, '2020-08-24', 995, 47.6313, '-', '-', 1, '-', '0', '-', 0, 970, 0, 309614.34),
(106, '2020-08-31', 0, '2020-08-31', 973, 47.786, '-', '-', 1, '-', '0', '-', 0, 970, 0, 305669.06),
(107, '2020-09-07', 0, '2020-09-07', 966, 48.0245, '-', '-', 1, '-', '0', '-', 0, 970, 0, 276519.12),
(108, '2020-09-12', 0, '2020-09-12', 1022, 49.2388, '-', '-', 1, '-', '0', '-', 0, 1022, 0, 266389.91),
(109, '2020-09-14', 0, '2020-09-14', 1016, 49.162, '-', '-', 1, '-', '0', '-', 0, 1016, 0, 334830.81),
(110, '2020-09-21', 0, '2020-09-21', 984, 48.2098, '-', '-', 1, '-', '0', '-', 0, 984, 0, 262813.66),
(111, '2020-09-28', 0, '2020-09-28', 1005, 48.8022, '-', '-', 1, '-', '0', '-', 0, 970, 0, 277279.41),
(112, '2020-10-05', 0, '2020-10-05', 1017, 49.5149, '-', '-', 1, '-', '0', '-', 0, 1017, 0, 298644.81),
(113, '2020-10-12', 0, '2020-10-12', 1005, 48.5162, '-', '-', 1, '-', '0', '-', 0, 1005, 0, 337269.00),
(114, '2020-10-07', 0, '2020-10-09', 962, 46.2398, '-', '-', 1, '-', '0', '-', 0, 962, 0, 268760.53),
(115, '2020-10-14', 0, '2020-10-14', 1011, 48.194, '-', '-', 1, '-', '0', '-', 0, 1011, 0, 269052.81),
(116, '2020-10-21', 2, '2020-10-23', 1011, 48.9652, '-', '-', 1, '-', '0', '-', 0, 1011, 0, 398133.50),
(117, '2020-10-28', 0, '2020-10-28', 1015, 49.2974, '-', '-', 1, '-', '-2', '-', 0, 0, 0, 349806.31),
(118, '2020-11-03', 2, '2020-11-05', 968, 49.7088, '-', '-', 1, '-', '-1', '-', 0, 0, 0, 457358.84),
(119, '2020-11-05', 0, '2020-11-05', 989, 49.0452, '-', '-', 1, '-', '-1', '-', 0, 989, 0, 303445.44),
(120, '2020-11-25', 2, '2020-11-27', 1009, 50.1612, '-', '-', 1, '-', '-1', '-', 0, 1009, 0, 261786.44),
(121, '2020-11-30', 0, '2020-11-30', 947, 49.0944, '-', '-', 1, '-', '-2', '-', 0, 947, 0, 287164.09);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `extra`
--

DROP TABLE IF EXISTS `extra`;
CREATE TABLE `extra` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_bolsas_bolsero` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `descripcion` varchar(255) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `pago` float NOT NULL,
  `estado` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `fruta`
--

DROP TABLE IF EXISTS `fruta`;
CREATE TABLE `fruta` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_productores` int(11) NOT NULL,
  `peso_kg` float NOT NULL,
  `pago` float NOT NULL,
  `saldo_abono` float DEFAULT 0,
  `cant_bolsas` int(5) DEFAULT 0,
  `id_embarque` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `fruta`
--

INSERT INTO `fruta` (`id`, `id_productores`, `peso_kg`, `pago`, `saldo_abono`, `cant_bolsas`, `id_embarque`) VALUES
('1001', 1, 7065.8, 4, 28263.2, 0, 100),
('10010', 14, 4228, 4, 16912, 0, 100),
('10011', 18, 3340.6, 4, 13362.4, 0, 100),
('10012', 4, 2174, 4, 8696, 0, 100),
('10013', 12, 1194.8, 4.5, 5376.6, 0, 100),
('1002', 15, 4585.9, 4, 18343.6, 0, 100),
('1003', 2, 2572.2, 4, 10288.8, 0, 100),
('1004', 3, 8016.2, 4, 32064.8, 0, 100),
('1005', 5, 6712.2, 4, 26848.8, 0, 100),
('1006', 6, 3155.4, 4, 12621.6, 0, 100),
('1007', 19, 1041.2, 4, 4164.8, 0, 100),
('1008', 10, 1314.2, 4, 5256.8, 0, 100),
('1009', 22, 1409.4, 4, 5637.6, 0, 100),
('1011', 1, 8596.8, 4, 34387.2, 0, 101),
('10110', 22, 1127.8, 4, 4511.2, 0, 101),
('10111', 14, 2453.4, 4, 9813.6, 0, 101),
('10112', 18, 1762.2, 4, 7048.8, 0, 101),
('10113', 4, 2828.6, 4, 11314.4, 0, 101),
('10114', 13, 1545, 4, 6180, 0, 101),
('10115', 41, 1830.2, 5, 9151, 0, 101),
('1012', 15, 3961.8, 5, 19809, 0, 101),
('1013', 2, 3413.4, 5, 17067, 0, 101),
('1014', 3, 6343.8, 4, 25375.2, 0, 101),
('1015', 5, 5090.8, 4, 20363.2, 0, 101),
('1016', 6, 1690.8, 4, 6763.2, 0, 101),
('1017', 19, 974.4, 4, 3897.6, 0, 101),
('1018', 10, 2664.6, 4, 10658.4, 0, 101),
('1019', 26, 914, 4, 3656, 0, 101),
('1021', 1, 7072, 4, 28288, 0, 102),
('10210', 4, 1796.8, 4, 7187.2, 0, 102),
('10211', 13, 2442.6, 4, 9770.4, 0, 102),
('10212', 42, 8048.8, 5, 40244, 0, 102),
('10213', 39, 569.2, 5, 2846, 0, 102),
('1022', 15, 3629, 4, 14516, 0, 102),
('1023', 2, 2097, 4, 8388, 0, 102),
('1024', 3, 6067.8, 4, 24271.2, 0, 102),
('1025', 5, 5186.6, 4, 20746.4, 0, 102),
('1026', 6, 2560.6, 4, 10242.4, 0, 102),
('1027', 10, 2488.6, 4, 9954.4, 0, 102),
('1028', 12, 2443.8, 4, 9775.2, 0, 102),
('1029', 22, 3214.8, 4, 12859.2, 0, 102),
('1031', 1, 8628, 4, 34512, 0, 103),
('10310', 14, 5284.4, 4, 21137.6, 0, 103),
('10311', 18, 2085.6, 4, 8342.4, 0, 103),
('10312', 19, 1663, 4, 6652, 0, 103),
('10313', 26, 776.4, 4, 3105.6, 0, 103),
('10314', 16, 1143.4, 4, 4573.6, 0, 103),
('10315', 40, 1017.6, 4, 4070.4, 0, 103),
('1032', 15, 3404.3, 4, 13617.2, 0, 103),
('1033', 2, 3664, 4, 14656, 0, 103),
('1034', 3, 5532.2, 4, 22128.8, 0, 103),
('1035', 5, 5653.8, 4, 22615.2, 0, 103),
('1036', 6, 3311.8, 4, 13247.2, 0, 103),
('1037', 12, 1027, 4.5, 4621.5, 0, 103),
('1038', 22, 1560, 4, 6240, 0, 103),
('1039', 4, 3023.8, 4, 12095.2, 0, 103),
('1041', 1, 6950.6, 4, 27802.4, 0, 104),
('10410', 18, 1514.2, 4, 6056.8, 0, 104),
('10411', 13, 6052.6, 4, 24210.4, 0, 104),
('10412', 16, 2102.2, 4, 8408.8, 0, 104),
('10413', 40, 309.6, 4, 1238.4, 0, 104),
('10414', 12, 1836.6, 4.5, 8264.7, 0, 104),
('1042', 2, 3823, 4, 15292, 0, 104),
('1043', 3, 6325.6, 4, 25302.4, 0, 104),
('1044', 5, 5793.6, 4, 23174.4, 0, 104),
('1045', 6, 3109.8, 4, 12439.2, 0, 104),
('1046', 10, 2425.2, 4, 9700.8, 0, 104),
('1047', 22, 2336.8, 4, 9347.2, 0, 104),
('1048', 4, 3028.3, 4, 12113.2, 0, 104),
('1049', 14, 1855.2, 4, 7420.8, 0, 104),
('1051', 1, 7154.2, 4, 28616.8, 0, 105),
('10510', 26, 1058, 4, 4232, 0, 105),
('10511', 22, 3004, 4, 12016, 0, 105),
('10512', 4, 3346.6, 4, 13386.4, 0, 105),
('10513', 14, 5250.2, 4, 21000.8, 0, 105),
('10514', 18, 2231.6, 4, 8926.4, 0, 105),
('10515', 16, 2900.2, 4, 11600.8, 0, 105),
('10516', 11, 390.4, 4, 1561.6, 0, 105),
('1052', 15, 4429.4, 4, 17717.6, 0, 105),
('1053', 2, 2047.2, 4, 8188.8, 0, 105),
('1054', 3, 4196.9, 4, 16787.6, 0, 105),
('1055', 5, 5435.2, 4, 21740.8, 0, 105),
('1056', 6, 1935, 4, 7740, 0, 105),
('1057', 12, 1223.6, 4.5, 5506.2, 0, 105),
('1058', 10, 1430.4, 4, 5721.6, 0, 105),
('1059', 19, 1598.4, 4, 6393.6, 0, 105),
('1061', 2, 4055.4, 4, 16221.6, 0, 106),
('10610', 18, 2188.6, 4, 8754.4, 0, 106),
('10611', 16, 2076.6, 4, 8306.4, 0, 106),
('10612', 25, 884.6, 4.5, 3980.7, 0, 106),
('10613', 13, 4344, 4, 17376, 0, 106),
('10614', 44, 1176.9, 4, 4707.6, 0, 106),
('10615', 45, 2568.9, 5, 12844.5, 0, 106),
('10616', 1, 6902, 4, 27608, 0, 106),
('1062', 3, 4723.2, 4, 18892.8, 0, 106),
('1063', 5, 4382.6, 4, 17530.4, 0, 106),
('1064', 6, 2724.4, 4, 10897.6, 0, 106),
('1065', 12, 883.4, 4.5, 3975.3, 0, 106),
('1066', 10, 2001, 4, 8004, 0, 106),
('1067', 19, 1039.2, 4, 4156.8, 0, 106),
('1068', 4, 2845.4, 4, 11381.6, 0, 106),
('1069', 14, 4989.8, 4, 19959.2, 0, 106),
('1071', 1, 7043.3, 4, 28173.2, 0, 107),
('10710', 4, 2976.4, 4, 11905.6, 0, 107),
('10711', 14, 5372.6, 4, 21490.4, 0, 107),
('10712', 18, 2142.8, 4, 8571.2, 0, 107),
('10713', 16, 1917, 4, 7668, 0, 107),
('1072', 15, 4146.2, 4, 16584.8, 0, 107),
('1073', 2, 3064.4, 4, 12257.6, 0, 107),
('1074', 3, 6092.6, 4, 24370.4, 0, 107),
('1075', 5, 7309.6, 4, 29238.4, 0, 107),
('1076', 6, 2327.4, 4, 9309.6, 0, 107),
('1077', 12, 732.2, 4.5, 3294.9, 0, 107),
('1078', 26, 570.3, 4, 2281.2, 0, 107),
('1079', 22, 4329.7, 4, 17318.8, 0, 107),
('1081', 1, 8662.4, 4, 34649.6, 0, 108),
('10810', 4, 3083, 4, 12332, 0, 108),
('10811', 14, 4532.2, 4, 18128.8, 0, 108),
('10812', 18, 2189.4, 4, 8757.6, 0, 108),
('10813', 13, 3391.6, 4, 13566.4, 0, 108),
('1082', 15, 3591.8, 4, 14367.2, 0, 108),
('1083', 2, 4026.4, 4, 16105.6, 0, 108),
('1084', 3, 6163, 4, 24652, 0, 108),
('1085', 5, 4049.8, 4, 16199.2, 0, 108),
('1086', 6, 3064.6, 4, 12258.4, 0, 108),
('1087', 10, 1590.8, 4, 6363.2, 0, 108),
('1088', 19, 1894.6, 4, 7578.4, 0, 108),
('1089', 22, 2999.2, 4, 11996.8, 0, 108),
('1091', 1, 6036.4, 4, 24145.6, 0, 109),
('10910', 22, 3256.4, 4, 13025.6, 0, 109),
('10911', 4, 2876, 4, 11504, 0, 109),
('10912', 14, 5339.8, 4, 21359.2, 0, 109),
('10913', 18, 2167.2, 4, 8668.8, 0, 109),
('10914', 16, 967, 4, 3868, 0, 109),
('10915', 40, 350.6, 4.5, 1577.7, 0, 109),
('10916', 11, 356.8, 5, 1784, 0, 109),
('1092', 15, 5081.6, 4, 20326.4, 0, 109),
('1093', 2, 4036.2, 4, 16144.8, 0, 109),
('1094', 3, 7537.2, 4, 30148.8, 0, 109),
('1095', 5, 4805, 4, 19220, 0, 109),
('1096', 6, 2906, 4, 11624, 0, 109),
('1097', 12, 1467.4, 4.5, 6603.3, 0, 109),
('1098', 10, 1275.4, 4, 5101.6, 0, 109),
('1099', 26, 703, 4, 2812, 0, 109),
('1101', 1, 6019.8, 4, 24079.2, 0, 110),
('11010', 22, 3482.6, 4, 13930.4, 0, 110),
('11011', 4, 2723.8, 4, 10895.2, 0, 110),
('11012', 14, 4497.6, 4, 17990.4, 0, 110),
('11013', 18, 3788, 4, 15152, 0, 110),
('11014', 40, 425, 4, 1700, 0, 110),
('11015', 13, 3716, 4, 14864, 0, 110),
('1102', 15, 2336.6, 4, 9346.4, 0, 110),
('1103', 2, 4073.2, 4, 16292.8, 0, 110),
('1104', 3, 7019.4, 4, 28077.6, 0, 110),
('1105', 5, 3863.4, 4, 15453.6, 0, 110),
('1106', 6, 2485.2, 4, 9940.8, 0, 110),
('1107', 12, 1109.6, 4.5, 4993.2, 0, 110),
('1108', 10, 1118.4, 4, 4473.6, 0, 110),
('1109', 19, 1551.2, 4, 6204.8, 0, 110),
('1111', 1, 9966.6, 4, 39866.4, 0, 111),
('11110', 22, 1516, 4, 6064, 0, 111),
('11111', 4, 2987.8, 4, 11951.2, 0, 111),
('11112', 14, 5404.2, 4, 21616.8, 0, 111),
('11113', 18, 2143.4, 4, 8573.6, 0, 111),
('11114', 26, 682, 4, 2728, 0, 111),
('11115', 40, 522.6, 4, 2090.4, 0, 111),
('1112', 15, 3335.4, 4, 13341.6, 0, 111),
('1113', 2, 3996.2, 4, 15984.8, 0, 111),
('1114', 3, 6964, 4, 27856, 0, 111),
('1115', 5, 4064.2, 4, 16256.8, 0, 111),
('1116', 6, 2833.2, 4, 11332.8, 0, 111),
('1117', 12, 1074.8, 4.5, 4836.6, 0, 111),
('1118', 10, 1983.8, 4, 7935.2, 0, 111),
('1119', 19, 1328, 4, 5312, 0, 111),
('1121', 1, 10920.8, 4, 43683.2, 0, 112),
('11210', 4, 2803.8, 4, 11215.2, 0, 112),
('11211', 14, 4423.8, 4, 17695.2, 0, 112),
('11212', 40, 511.2, 4, 2044.8, 0, 112),
('11213', 13, 4008, 4, 16032, 0, 112),
('1122', 15, 3160.2, 4, 12640.8, 0, 112),
('1123', 2, 4117, 4, 16468, 0, 112),
('1124', 3, 6139, 4, 24556, 0, 112),
('1125', 5, 3858.4, 4, 15433.6, 0, 112),
('1126', 6, 2700.8, 4, 10803.2, 0, 112),
('1127', 12, 1242.4, 4.5, 5590.8, 0, 112),
('1128', 10, 2534.6, 4, 10138.4, 0, 112),
('1129', 22, 3094.9, 4, 12379.6, 0, 112),
('1131', 1, 10800, 4, 43200, 0, 113),
('11310', 4, 3507, 4, 14028, 0, 113),
('11311', 14, 4025, 4, 16100, 0, 113),
('11312', 40, 571.2, 4, 2284.8, 0, 113),
('11313', 13, 0, 4, 0, 0, 113),
('11314', 18, 4060, 4, 16240, 0, 113),
('11315', 19, 1686.2, 4, 6744.8, 0, 113),
('11316', 26, 482, 4, 1928, 0, 113),
('1132', 15, 2092.2, 4, 8368.8, 0, 113),
('1133', 2, 3025.8, 4, 12103.2, 0, 113),
('1134', 3, 6090.6, 4, 24362.4, 0, 113),
('1135', 5, 3054, 4, 12216, 0, 113),
('1136', 6, 3205.2, 4, 12820.8, 0, 113),
('1137', 12, 978.4, 4, 3913.6, 0, 113),
('1138', 10, 1940.8, 4, 7763.2, 0, 113),
('1139', 22, 2997.8, 4, 11991.2, 0, 113),
('1141', 1, 14135.6, 4, 56542.4, 0, 114),
('11410', 22, 587, 4, 2348, 0, 114),
('11411', 14, 3162.8, 4, 12651.2, 0, 114),
('11412', 40, 692.2, 4, 2768.8, 0, 114),
('11413', 32, 1136, 4, 1524, 0, 114),
('11414', 3, 4765.4, 4, 19061.6, 0, 114),
('1142', 15, 5804.2, 4, 23216.8, 0, 114),
('1143', 2, 4101.4, 4, 16405.6, 0, 114),
('1144', 4, 2777.2, 4, 11108.8, 0, 114),
('1145', 5, 2572.2, 4, 10288.8, 0, 114),
('1146', 6, 2911.4, 4, 11645.6, 0, 114),
('1147', 18, 2005.4, 4, 8021.6, 0, 114),
('1148', 19, 654.4, 4, 2617.6, 0, 114),
('1149', 10, 2070.6, 4, 8282.4, 0, 114),
('1151', 1, 13473.4, 4, 53893.6, 0, 115),
('11510', 12, 995.6, 4.5, 4480.2, 0, 115),
('11511', 26, 384.8, 4, 1539.2, 0, 115),
('11512', 22, 2797.4, 4, 11189.6, 0, 115),
('11513', 14, 4156.6, 4, 16626.4, 0, 115),
('11514', 40, 486.4, 4, 1945.6, 0, 115),
('1152', 15, 5393.4, 4, 21573.6, 0, 115),
('1153', 2, 2510.8, 4, 10043.2, 0, 115),
('1154', 3, 5350, 4, 21400, 0, 115),
('1155', 4, 2009.6, 4, 8038.4, 0, 115),
('1156', 5, 3085.6, 4, 12342.4, 0, 115),
('1157', 6, 2554.6, 4, 10218.4, 0, 115),
('1158', 18, 2007.8, 4, 8031.2, 0, 115),
('1159', 10, 2988, 4, 11952, 0, 115),
('1161', 1, 14201.6, 4, 56806.4, 0, 116),
('11610', 12, 1304.6, 4.5, 5870.7, 0, 116),
('11611', 22, 1872.8, 4, 7491.2, 0, 116),
('11612', 14, 2102.6, 4, 8410.4, 0, 116),
('11613', 40, 379.6, 4, 1518.4, 0, 116),
('11614', 11, 357, 4, 1428, 0, 116),
('1162', 15, 6101.6, 4, 24406.4, 0, 116),
('1163', 2, 2520, 4, 10080, 0, 116),
('1164', 4, 2132.6, 4, 8530.4, 0, 116),
('1165', 5, 3217.2, 4, 12868.8, 0, 116),
('1166', 3, 6127.6, 4, 24510.4, 0, 116),
('1167', 6, 3468.4, 4, 13873.6, 0, 116),
('1168', 19, 1810, 4, 7240, 0, 116),
('1169', 10, 3369.6, 4, 13478.4, 0, 116),
('1171', 1, 13983.2, 4, 55932.8, 0, 117),
('11710', 4, 1207.8, 4, 4831.2, 0, 117),
('11711', 14, 4165, 4, 16660, 0, 117),
('11712', 18, 3890.8, 4, 15563.2, 0, 117),
('11713', 40, 606.2, 4, 2424.8, 0, 117),
('1172', 15, 4661.8, 4, 18647.2, 0, 117),
('1173', 2, 2333.4, 4, 9333.6, 0, 117),
('1174', 3, 5594.4, 4, 22377.6, 0, 117),
('1175', 5, 3308.8, 4, 13235.2, 0, 117),
('1176', 6, 3081, 4, 12324, 0, 117),
('1177', 12, 1468.8, 4.5, 6609.6, 0, 117),
('1178', 10, 2007, 4, 8028, 0, 117),
('1179', 22, 2989.2, 4, 11956.8, 0, 117),
('1181', 1, 13438, 4, 53752, 0, 118),
('11810', 11, 442.4, 4, 1769.6, 0, 118),
('11811', 19, 1844.8, 4, 7379.2, 0, 118),
('11812', 15, 4046.2, 4, 16184.8, 0, 118),
('11813', 26, 603.2, 4, 2412.8, 0, 118),
('11814', 4, 2325.2, 4, 9300.8, 0, 118),
('11815', 40, 501.6, 4, 2006.4, 0, 118),
('11816', 18, 3838.6, 4, 15354.4, 0, 118),
('1182', 5, 1853.4, 4, 7413.6, 0, 118),
('1183', 22, 2422.8, 4, 9691.2, 0, 118),
('1184', 12, 1262.8, 4.5, 5682.6, 0, 118),
('1185', 10, 2551.6, 4, 10206.4, 0, 118),
('1186', 6, 3374, 4, 13496, 0, 118),
('1187', 2, 2543.6, 4, 10174.4, 0, 118),
('1188', 14, 3311.2, 4, 13244.8, 0, 118),
('1189', 3, 5349.4, 4, 21397.6, 0, 118),
('1191', 1, 13851.7, 4, 55406.8, 0, 119),
('11910', 10, 2500.2, 4, 10000.8, 0, 119),
('11911', 12, 1999.8, 4.5, 8999.1, 0, 119),
('11912', 22, 2500.2, 4, 10000.8, 0, 119),
('11913', 40, 522.4, 4, 2089.6, 0, 119),
('11914', 14, 3350.6, 4, 13402.4, 0, 119),
('1192', 15, 4327, 4, 17308, 0, 119),
('1193', 2, 2999.7, 4, 11998.8, 0, 119),
('1194', 3, 5496.8, 4, 21987.2, 0, 119),
('1195', 4, 2550, 4, 10200, 0, 119),
('1196', 5, 1877, 4, 7508, 0, 119),
('1197', 6, 2366.4, 4, 9465.6, 0, 119),
('1198', 18, 3268.8, 4, 13075.2, 0, 119),
('1199', 19, 1434.6, 4, 5738.4, 0, 119),
('1201', 15, 5518.4, 4, 22073.6, 0, 120),
('12010', 26, 418.4, 4, 1673.6, 0, 120),
('12011', 5, 1559.4, 4, 6237.6, 0, 120),
('12012', 18, 3569.4, 4, 14277.6, 0, 120),
('12013', 12, 2063.2, 4.5, 9284.4, 0, 120),
('12014', 40, 628.4, 4, 2513.6, 0, 120),
('12015', 19, 1054.8, 4, 4219.2, 0, 120),
('12016', 14, 3553.6, 4, 14214.4, 0, 120),
('1202', 10, 2020.6, 4, 8082.4, 0, 120),
('1203', 6, 2537.6, 4, 10150.4, 0, 120),
('1204', 22, 1763.2, 4, 7052.8, 0, 120),
('1205', 2, 2094.2, 4, 8376.8, 0, 120),
('1206', 4, 2534.8, 4, 10139.2, 0, 120),
('1207', 3, 6159.4, 4, 24637.6, 0, 120),
('1208', 11, 572.6, 4, 2290.4, 0, 120),
('1209', 1, 14113.2, 4, 56452.8, 201, 120),
('1211', 1, 10493.2, 4, 41972.8, 0, 121),
('12110', 12, 1423, 4.5, 6403.5, 0, 121),
('12111', 26, 436.4, 4, 1745.6, 0, 121),
('12112', 22, 2046.4, 4, 8185.6, 0, 121),
('12113', 14, 4930.2, 4, 19720.8, 0, 121),
('12114', 40, 922.8, 4, 3691.2, 0, 121),
('12115', 11, 123.4, 4, 493.6, 0, 121),
('1212', 15, 7749.4, 4, 30997.6, 0, 121),
('1213', 2, 3379.4, 4, 13517.6, 0, 121),
('1214', 3, 6529.4, 4, 26117.6, 0, 121),
('1215', 4, 2985, 4, 11940, 0, 121),
('1216', 5, 2208.2, 4, 8832.8, 0, 121),
('1217', 6, 2513.8, 4, 10055.2, 0, 121),
('1218', 19, 1527.4, 4, 6109.6, 0, 121),
('1219', 10, 1826.4, 4, 7305.6, 0, 121),
('771', 1, 36750.6, 4, 147002, 0, 77),
('7710', 10, 1198.2, 4, 4792.8, 0, 77),
('7711', 11, 191.4, 4, 765.6, 0, 77),
('7712', 12, 1672.2, 4, 6688.8, 0, 77),
('7713', 13, 4063.8, 4, 16255.2, 0, 77),
('7714', 14, 8811.4, 4, 35245.6, 0, 77),
('772', 2, 5364, 4, 21456, 0, 77),
('773', 3, 6428.6, 4, 25714.4, 0, 77),
('774', 4, 1338, 4, 5352, 0, 77),
('775', 5, 1613.6, 4, 6454.4, 0, 77),
('776', 6, 1565, 4, 6260, 0, 77),
('777', 7, 1243.4, 4, 4973.6, 0, 77),
('778', 8, 739.4, 4, 2957.6, 0, 77),
('779', 9, 711.2, 4, 2844.8, 0, 77),
('781', 15, 7026.2, 4, 28104.8, 0, 78),
('7810', 19, 1760.2, 4, 7040.8, 0, 78),
('7811', 10, 776.6, 4, 3106.4, 0, 78),
('7812', 20, 1070.8, 4, 4283.2, 0, 78),
('7813', 21, 2360, 4, 9440, 0, 78),
('7814', 22, 2581.2, 4, 10324.8, 0, 78),
('7815', 23, 2418, 4, 9672, 0, 78),
('7816', 24, 869.2, 4, 3476.8, 0, 78),
('7817', 25, 1789, 4, 7156, 0, 78),
('782', 2, 2446, 4, 9784, 0, 78),
('783', 3, 5187.6, 4, 20750.4, 0, 78),
('784', 4, 1875.4, 4, 7501.6, 0, 78),
('785', 6, 2642.8, 4, 10571.2, 0, 78),
('786', 16, 9807.2, 4, 39228.8, 0, 78),
('787', 17, 2646, 4, 10584, 0, 78),
('788', 18, 1674.8, 4, 6699.2, 0, 78),
('789', 9, 586.2, 4, 2344.8, 0, 78),
('791', 1, 10120, 4, 40480, 0, 79),
('7910', 18, 1790.8, 4, 7163.2, 0, 79),
('7911', 8, 446.6, 4, 1786.4, 0, 79),
('7912', 26, 686.8, 4, 2747.2, 0, 79),
('7913', 10, 760.2, 4, 3040.8, 0, 79),
('7914', 11, 182.6, 4, 730.4, 0, 79),
('7915', 27, 648.8, 4, 2595.2, 0, 79),
('7916', 12, 1505.6, 4, 6022.4, 0, 79),
('7917', 28, 714.6, 3.8, 2715.48, 0, 79),
('7918', 22, 1129.4, 4, 4517.6, 0, 79),
('7919', 23, 1081, 4, 4324, 0, 79),
('792', 15, 3454.4, 4, 13817.6, 0, 79),
('7920', 29, 269.8, 4, 1079.2, 0, 79),
('7921', 13, 2554.8, 4, 10219.2, 0, 79),
('7922', 25, 1217.4, 4, 4869.6, 0, 79),
('793', 2, 867.4, 4, 3469.6, 0, 79),
('794', 3, 4882.4, 4, 19529.6, 0, 79),
('795', 4, 3176.8, 4, 12707.2, 0, 79),
('796', 5, 2236.8, 4, 8947.2, 0, 79),
('797', 6, 4550, 4, 18200, 0, 79),
('798', 7, 1078.4, 4, 4313.6, 0, 79),
('799', 16, 2582.8, 3.8, 9814.64, 0, 79),
('801', 1, 10059.8, 4, 40239.2, 0, 80),
('8010', 12, 1351.8, 4, 5407.2, 0, 80),
('8011', 23, 988.8, 4, 3955.2, 0, 80),
('8012', 14, 5568.6, 4, 22274.4, 0, 80),
('802', 2, 4740.8, 4, 18963.2, 0, 80),
('803', 3, 10281.2, 4, 41124.8, 0, 80),
('804', 4, 706.8, 4, 2827.2, 0, 80),
('805', 5, 2314.8, 4, 9259.2, 0, 80),
('806', 6, 1922.2, 4, 7688.8, 0, 80),
('807', 16, 1440.4, 4, 5761.6, 0, 80),
('808', 17, 2021, 4, 8084, 0, 80),
('809', 20, 1353, 4, 5412, 0, 80),
('811', 30, 8199.8, 4.5, 36899.1, 0, 81),
('8110', 8, 846.6, 4, 3386.4, 0, 81),
('8111', 19, 1977.2, 4, 7908.8, 0, 81),
('8112', 10, 1633, 4, 6532, 0, 81),
('8113', 27, 484.6, 4, 1938.4, 0, 81),
('8114', 26, 403.2, 4, 1612.8, 0, 81),
('8115', 24, 1700, 4, 6800, 0, 81),
('812', 31, 2062, 4.5, 9279, 0, 81),
('813', 15, 8907, 4, 35628, 0, 81),
('814', 2, 1279.4, 4, 5117.6, 0, 81),
('815', 4, 2326, 4, 9304, 0, 81),
('816', 6, 993.8, 4, 3975.2, 0, 81),
('817', 9, 2504, 4, 10016, 0, 81),
('818', 16, 3196, 4, 12784, 0, 81),
('819', 18, 2972.2, 4, 11888.8, 0, 81),
('821', 12, 1097.8, 4.5, 4940.1, 0, 82),
('8210', 16, 2084.4, 4, 8337.6, 0, 82),
('8211', 7, 1101.6, 4, 4406.4, 0, 82),
('8212', 8, 1114.4, 4, 4457.6, 0, 82),
('8213', 28, 846.4, 4, 3385.6, 0, 82),
('8214', 19, 1341, 4, 5364, 0, 82),
('8215', 10, 906.4, 4, 3625.6, 0, 82),
('8216', 26, 758.2, 4, 3032.8, 0, 82),
('8217', 22, 1900, 4, 7600, 0, 82),
('8218', 13, 2533.8, 4, 10135.2, 0, 82),
('8219', 14, 2507.4, 4, 10029.6, 0, 82),
('822', 1, 10022.7, 4, 40090.8, 0, 82),
('823', 15, 6847.8, 4, 27391.2, 0, 82),
('824', 2, 1251.8, 4, 5007.2, 0, 82),
('825', 3, 5509.2, 4, 22036.8, 0, 82),
('826', 4, 1756.6, 4, 7026.4, 0, 82),
('827', 5, 2732.6, 4, 10930.4, 0, 82),
('828', 6, 2923.4, 4, 11693.6, 0, 82),
('829', 9, 1448.6, 4, 5794.4, 0, 82),
('831', 12, 1188.8, 4.5, 5349.6, 0, 83),
('8310', 9, 743.6, 4, 2974.4, 0, 83),
('8311', 6, 3024, 4, 12096, 0, 83),
('8312', 5, 2649.6, 4, 10598.4, 0, 83),
('8313', 4, 1846.2, 4, 7384.8, 0, 83),
('8314', 3, 8214, 4, 32856, 0, 83),
('8315', 2, 3964.8, 4, 15859.2, 0, 83),
('8316', 15, 5281.4, 4, 21125.6, 0, 83),
('8317', 1, 5690.6, 4, 22762.4, 0, 83),
('832', 14, 2270.8, 4, 9083.2, 0, 83),
('833', 11, 209.4, 4, 837.6, 0, 83),
('834', 30, 4061, 4, 16244, 0, 83),
('835', 10, 2178.4, 4, 8713.6, 0, 83),
('836', 8, 795.2, 4, 3180.8, 0, 83),
('837', 18, 3252.4, 4, 13009.6, 0, 83),
('838', 17, 1539.8, 4, 6159.2, 0, 83),
('839', 16, 1396.4, 4, 5585.6, 0, 83),
('841', 1, 9628.4, 4, 38513.6, 0, 84),
('8410', 19, 2337.4, 4, 9349.6, 0, 84),
('8411', 10, 2554.2, 4, 10216.8, 0, 84),
('8412', 30, 3729, 4, 14916, 0, 84),
('8413', 11, 221.6, 4, 886.4, 0, 84),
('8414', 22, 2331.8, 4, 9327.2, 0, 84),
('8415', 13, 2465.4, 4, 9861.6, 0, 84),
('8416', 14, 2483.8, 4, 9935.2, 0, 84),
('842', 2, 1455.2, 4, 5820.8, 0, 84),
('843', 3, 7816.2, 4, 31264.8, 0, 84),
('844', 4, 2495.2, 4, 9980.8, 0, 84),
('845', 5, 4188.8, 4, 16755.2, 0, 84),
('846', 6, 2291, 4, 9164, 0, 84),
('847', 16, 1438.6, 4, 5754.4, 0, 84),
('848', 17, 1523, 4, 6092, 0, 84),
('849', 18, 2290, 4, 9160, 0, 84),
('851', 12, 1536.4, 4.5, 6913.8, 0, 85),
('8510', 10, 837.6, 4, 3350.4, 0, 85),
('8511', 26, 507.6, 4, 2030.4, 0, 85),
('8512', 22, 1130, 4, 4520, 0, 85),
('8513', 13, 675.8, 4, 2703.2, 0, 85),
('8514', 14, 975.6, 4, 3902.4, 0, 85),
('852', 1, 11291.8, 4, 45167.2, 0, 85),
('853', 15, 3919.6, 4, 15678.4, 0, 85),
('854', 2, 4004.7, 4, 16018.8, 0, 85),
('855', 3, 8004.4, 4, 32017.6, 0, 85),
('856', 4, 2398.8, 4, 9595.2, 0, 85),
('857', 5, 3724, 4, 14896, 0, 85),
('858', 6, 2414.4, 4, 9657.6, 0, 85),
('859', 19, 1028, 4, 4112, 0, 85),
('861', 12, 1372.8, 4.5, 6177.6, 0, 86),
('8610', 10, 1160.8, 4, 4643.2, 0, 86),
('8611', 30, 2373.6, 4, 9494.4, 0, 86),
('8612', 11, 276.8, 4, 1107.2, 0, 86),
('8613', 26, 695.4, 4, 2781.6, 0, 86),
('8614', 22, 1529, 4, 6116, 0, 86),
('8615', 13, 1078.4, 4, 4313.6, 0, 86),
('8616', 14, 425.2, 4, 1700.8, 0, 86),
('862', 1, 12244.8, 4, 48979.2, 0, 86),
('863', 15, 3181.6, 4, 12726.4, 0, 86),
('864', 2, 3906, 4, 15624, 0, 86),
('865', 3, 7402, 4, 29608, 0, 86),
('866', 4, 1985, 4, 7940, 0, 86),
('867', 5, 3758.6, 4, 15034.4, 0, 86),
('868', 6, 2692.6, 4, 10770.4, 0, 86),
('869', 18, 2321.6, 4, 9286.4, 0, 86),
('871', 12, 1335.4, 4.5, 6009.3, 0, 87),
('8710', 10, 1150.4, 4, 4601.6, 0, 87),
('8711', 11, 426.8, 4, 1707.2, 0, 87),
('8712', 24, 1489.4, 4, 5957.6, 0, 87),
('8713', 13, 586.2, 4, 2344.8, 0, 87),
('8714', 14, 1407.4, 4, 5629.6, 0, 87),
('872', 1, 12955.4, 4, 51821.6, 0, 87),
('873', 15, 3064.2, 4, 12256.8, 0, 87),
('874', 2, 3151.2, 4, 12604.8, 0, 87),
('875', 3, 6859.2, 4, 27436.8, 0, 87),
('876', 4, 2043, 4, 8172, 0, 87),
('877', 5, 4047, 4, 16188, 0, 87),
('878', 6, 3156.8, 4, 12627.2, 0, 87),
('879', 18, 2324.2, 4, 9296.8, 0, 87),
('881', 1, 12962, 4, 51848, 0, 88),
('8810', 19, 1073.2, 4, 4292.8, 0, 88),
('8811', 10, 1074.6, 4, 4298.4, 0, 88),
('8812', 11, 140.8, 4, 563.2, 0, 88),
('8813', 26, 558.6, 4, 2234.4, 0, 88),
('8814', 22, 1205.4, 4, 4821.6, 0, 88),
('8815', 24, 948.6, 4, 3794.4, 0, 88),
('8816', 13, 2041.6, 4, 8166.4, 0, 88),
('882', 15, 3992.2, 4, 15968.8, 0, 88),
('883', 2, 4165.2, 4, 16660.8, 0, 88),
('884', 3, 7114.2, 4, 28456.8, 0, 88),
('885', 4, 2891.2, 4, 11564.8, 0, 88),
('886', 5, 3796.4, 4, 15185.6, 0, 88),
('887', 6, 3544.4, 4, 14177.6, 0, 88),
('888', 9, 1357.6, 4, 5430.4, 0, 88),
('889', 18, 2384.4, 4, 9537.6, 0, 88),
('891', 12, 1561.4, 4.5, 7026.3, 0, 89),
('8910', 19, 1278, 4, 5112, 0, 89),
('8911', 10, 1495.6, 4, 5982.4, 0, 89),
('8912', 26, 801.4, 4, 3205.6, 0, 89),
('8913', 22, 1391.8, 4, 5567.2, 0, 89),
('8914', 14, 2543.4, 4, 10173.6, 0, 89),
('892', 1, 8881.2, 4, 35524.8, 0, 89),
('893', 15, 4866.2, 4, 19464.8, 0, 89),
('894', 2, 4271.6, 4, 17086.4, 0, 89),
('895', 3, 7965.2, 4, 31860.8, 0, 89),
('896', 4, 3061.2, 4, 12244.8, 0, 89),
('897', 5, 3785.2, 4, 15140.8, 0, 89),
('898', 6, 2962.2, 4, 11848.8, 0, 89),
('899', 18, 1975.8, 4, 7903.2, 0, 89),
('901', 1, 10149.6, 4, 40598.4, 0, 90),
('9010', 10, 1521.8, 4, 6087.2, 0, 90),
('9011', 11, 453, 4, 1812, 0, 90),
('9012', 26, 518.6, 4, 2074.4, 0, 90),
('9013', 22, 1686.2, 4, 6744.8, 0, 90),
('9014', 13, 2525.6, 4, 10102.4, 0, 90),
('902', 15, 4315, 4, 17260, 0, 90),
('903', 2, 4172.8, 4, 16691.2, 0, 90),
('904', 3, 9341, 4, 37364, 0, 90),
('905', 4, 2536, 4, 10144, 0, 90),
('906', 5, 3815.8, 4, 15263.2, 0, 90),
('907', 6, 3297, 4, 13188, 0, 90),
('908', 18, 2121.6, 4, 8486.4, 0, 90),
('909', 19, 1343.4, 4, 5373.6, 0, 90),
('911', 12, 3172, 4.5, 14274, 0, 91),
('9110', 19, 990.8, 4, 3963.2, 0, 91),
('9111', 11, 509, 4, 2036, 0, 91),
('9112', 22, 985.4, 4, 3941.6, 0, 91),
('9113', 14, 2531, 4, 10124, 0, 91),
('912', 1, 11000, 4, 44000, 0, 91),
('913', 15, 3950, 4, 15800, 0, 91),
('914', 2, 4413.8, 4, 17655.2, 0, 91),
('915', 3, 8550, 4, 34200, 0, 91),
('916', 4, 3357, 4, 13428, 0, 91),
('917', 5, 3525.2, 4, 14100.8, 0, 91),
('918', 6, 3943, 4, 15772, 0, 91),
('919', 18, 1853.4, 4, 7413.6, 0, 91),
('921', 1, 65865, 4, 263460, 0, 92),
('9210', 10, 678.4, 4, 2713.6, 0, 92),
('9211', 12, 1215.4, 4.5, 5469.3, 0, 92),
('9212', 26, 1050.2, 4, 4200.8, 0, 92),
('9213', 22, 1292, 4, 5168, 0, 92),
('9214', 13, 2748.6, 4, 10994.4, 0, 92),
('922', 15, 4139.4, 4, 16557.6, 0, 92),
('923', 2, 4008.4, 4, 16033.6, 0, 92),
('924', 3, 8612.4, 4, 34449.6, 0, 92),
('925', 4, 3052.4, 4, 12209.6, 0, 92),
('926', 5, 3219, 4, 12876, 0, 92),
('927', 6, 3070, 4, 12280, 0, 92),
('928', 18, 1404, 4, 5616, 0, 92),
('929', 19, 1115.2, 4, 4460.8, 0, 92),
('931', 1, 10874.7, 4, 43498.8, 0, 93),
('9310', 12, 2839.2, 4.5, 12776.4, 0, 93),
('9311', 26, 507.8, 4, 2031.2, 0, 93),
('9312', 22, 1022.4, 4, 4089.6, 0, 93),
('9313', 14, 2591.6, 4, 10366.4, 0, 93),
('932', 15, 4009, 4, 16036, 0, 93),
('933', 2, 3238.2, 4, 12952.8, 0, 93),
('934', 3, 7254.2, 4, 29016.8, 0, 93),
('935', 4, 2994.4, 4, 11977.6, 0, 93),
('936', 6, 3063.6, 4, 12254.4, 0, 93),
('937', 18, 1568.2, 4, 6272.8, 0, 93),
('938', 10, 1003.2, 4, 4012.8, 0, 93),
('939', 11, 359.8, 4, 1439.2, 0, 93),
('941', 1, 9905.2, 4, 39620.8, 0, 94),
('9410', 10, 808.8, 4, 3235.2, 0, 94),
('9411', 22, 1363.8, 4, 5455.2, 0, 94),
('9412', 13, 2853.4, 4, 11413.6, 0, 94),
('9413', 12, 2253.4, 4.5, 10140.3, 0, 94),
('942', 15, 3496.2, 4, 13984.8, 0, 94),
('943', 2, 5012.8, 4, 20051.2, 0, 94),
('944', 3, 8330.2, 4, 33320.8, 0, 94),
('945', 4, 3003, 4, 12012, 0, 94),
('946', 5, 5013.2, 4, 20052.8, 0, 94),
('947', 18, 1464.4, 4, 5857.6, 0, 94),
('948', 6, 2420.8, 4, 9683.2, 0, 94),
('949', 19, 1548, 4, 6192, 0, 94),
('951', 1, 5603.19, 4, 22412.8, 0, 95),
('9510', 10, 2019.4, 4, 8077.6, 0, 95),
('9511', 11, 482.9, 4, 1931.6, 0, 95),
('9512', 26, 1023.6, 4, 4094.4, 0, 95),
('9513', 22, 1645.7, 4, 6582.8, 0, 95),
('9514', 14, 3953.5, 4, 15814, 0, 95),
('9515', 12, 1451.8, 4.5, 6533.1, 0, 95),
('952', 15, 4963, 4, 19852, 0, 95),
('953', 2, 5012, 4, 20048, 0, 95),
('954', 3, 7435.4, 4, 29741.6, 0, 95),
('955', 4, 4249.4, 4, 16997.6, 0, 95),
('956', 5, 3622.8, 4, 14491.2, 0, 95),
('957', 6, 3017.6, 4, 12070.4, 0, 95),
('958', 18, 1648.2, 4, 6592.8, 0, 95),
('959', 19, 1370.9, 4, 5483.6, 0, 95),
('961', 1, 10016.6, 4, 40066.4, 0, 96),
('9610', 22, 1187.6, 4, 4750.4, 0, 96),
('9611', 14, 3042, 4, 12168, 0, 96),
('9612', 12, 1532.9, 4.5, 6898.05, 0, 96),
('962', 15, 4245.6, 4, 16982.4, 0, 96),
('963', 2, 4428.3, 4, 17713.2, 0, 96),
('964', 3, 7634.6, 4, 30538.4, 0, 96),
('965', 4, 3506.8, 4, 14027.2, 0, 96),
('966', 5, 4513.6, 4, 18054.4, 0, 96),
('967', 6, 2242, 4, 8968, 0, 96),
('968', 18, 2308.6, 4, 9234.4, 0, 96),
('969', 10, 839.6, 4, 3358.4, 0, 96),
('971', 1, 9580, 4, 38320, 0, 97),
('9710', 10, 1886.4, 4, 7545.6, 0, 97),
('9711', 11, 129, 4, 516, 0, 97),
('9712', 26, 784.6, 4, 3138.4, 0, 97),
('9713', 22, 1525.4, 4, 6101.6, 0, 97),
('9714', 14, 3079.8, 4, 12319.2, 0, 97),
('9715', 12, 1472, 4.5, 6624, 0, 97),
('972', 15, 3556.4, 4, 14225.6, 0, 97),
('973', 2, 3883, 4, 15532, 0, 97),
('974', 3, 8014.4, 4, 32057.6, 0, 97),
('975', 4, 3028.6, 4, 12114.4, 0, 97),
('976', 5, 4048.4, 4, 16193.6, 0, 97),
('977', 6, 2647.2, 4, 10588.8, 0, 97),
('978', 18, 2014.6, 4, 8058.4, 0, 97),
('979', 19, 1036.4, 4, 4145.6, 0, 97),
('981', 1, 7068.2, 4, 28272.8, 0, 98),
('9810', 11, 210.4, 4, 841.6, 0, 98),
('9811', 22, 862.6, 4, 3450.4, 0, 98),
('9812', 13, 3898.4, 4, 15593.6, 0, 98),
('9813', 32, 459.6, 4, 1838.4, 0, 98),
('982', 15, 797, 4, 3188, 0, 98),
('983', 2, 3198, 4, 12792, 0, 98),
('984', 3, 5613, 4, 22452, 0, 98),
('985', 4, 4598.6, 4, 18394.4, 0, 98),
('986', 5, 3455.8, 4, 13823.2, 0, 98),
('987', 6, 2171, 4, 8684, 0, 98),
('988', 18, 2724.6, 4, 10898.4, 0, 98),
('989', 10, 1834.8, 4, 7339.2, 0, 98),
('991', 1, 5785.4, 4, 23141.6, 0, 99),
('9910', 22, 2170, 4, 8680, 0, 99),
('9911', 14, 3291.8, 4, 13167.2, 0, 99),
('9912', 33, 1560.2, 5, 7801, 0, 99),
('9913', 34, 1801.8, 5, 9009, 0, 99),
('9914', 35, 952, 5, 4760, 0, 99),
('9915', 36, 1454.4, 5, 7272, 0, 99),
('9916', 37, 878.4, 5, 4392, 0, 99),
('9917', 38, 991, 5, 4955, 0, 99),
('9918', 39, 547.4, 4.5, 2463.3, 0, 99),
('9919', 40, 1379, 5, 6895, 0, 99),
('992', 15, 5566.6, 4, 22266.4, 0, 99),
('993', 2, 2567.2, 4, 10268.8, 0, 99),
('994', 3, 5908, 4, 23632, 0, 99),
('995', 5, 4831, 4, 19324, 0, 99),
('996', 6, 1788.8, 4, 7155.2, 0, 99),
('997', 19, 974, 4, 3896, 0, 99),
('998', 10, 1977, 4, 7908, 0, 99),
('999', 12, 1163.6, 4.5, 5236.2, 0, 99);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos`
--

DROP TABLE IF EXISTS `gastos`;
CREATE TABLE `gastos` (
  `id_gasto` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `gastos`
--

INSERT INTO `gastos` (`id_gasto`, `nombre`) VALUES
(1, 'FRUTA'),
(2, 'PELADORES'),
(3, 'BOLSEROS'),
(4, 'PLANILLA TOSTON'),
(5, 'COMPRA BOLSAS'),
(6, 'RENTA DE PELADORA'),
(7, 'RENTA TOSTON'),
(8, 'RENTA AP.'),
(9, 'E. E. PELADORA'),
(10, 'E. E. PELADORA 2'),
(11, 'E. E. TOSTON'),
(12, 'A. E. CH.'),
(13, 'JAGV'),
(14, 'AGENTE ADUANERO'),
(15, 'CONTADOR'),
(16, 'GUIA'),
(17, 'GASOLINA CAMIONETA'),
(18, 'GASOLINA CARRO'),
(19, 'RENTA CAMIONETA'),
(20, 'FERTILIZANTE'),
(21, 'PRESTAMOS'),
(22, 'GASTOS'),
(23, 'FERTILIZANTE PRODUCTORES ABONO'),
(24, 'PRESTAMOS PRODUCTORES ABONO'),
(25, 'COPERACIONES'),
(26, 'AGUA PURIFICADA'),
(27, 'AGUINALDO'),
(28, 'FUNGICIDA'),
(29, 'FUNGICIDA PRODUCTORES ABONO'),
(30, 'COPERACIONES');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos_embarque`
--

DROP TABLE IF EXISTS `gastos_embarque`;
CREATE TABLE `gastos_embarque` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `id_gasto` int(11) NOT NULL,
  `cantidad` float(10,2) NOT NULL,
  `extra` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `gastos_embarque`
--

INSERT INTO `gastos_embarque` (`id`, `id_embarque`, `id_gasto`, `cantidad`, `extra`) VALUES
('1001', 100, 1, 177836.98, ''),
('10010', 100, 22, 750.00, 'PELADORA (INTERNET PELADORA)'),
('10011', 100, 22, 798.00, 'PELADORA (INTERNET TOSTON)'),
('10012', 100, 22, 500.00, 'PELADORA (APOYO ELEAZAR)'),
('10013', 100, 14, 2774.00, ''),
('10014', 100, 16, 200.00, ''),
('10015', 100, 12, 8000.00, ''),
('10016', 100, 22, 250.00, 'NANCY'),
('10017', 100, 26, 100.00, ''),
('10018', 100, 22, 200.00, 'GASOLINA ADRIAN'),
('10019', 100, 22, 200.00, 'GASOLINA MCKLIN'),
('1002', 100, 3, 11400.00, ''),
('10020', 100, 13, 100000.00, ''),
('10021', 100, 22, 0.00, 'ABONO PRESTAMO'),
('10022', 100, 22, 200.00, 'GASOLINA NOE '),
('10023', 100, 22, 20000.00, 'RENTA TOSTON JULIO'),
('10024', 100, 15, 8500.00, ''),
('10025', 100, 22, 8000.00, 'APP JOSE'),
('10026', 100, 27, 3000.00, ''),
('10027', 100, 19, 1100.00, ''),
('10028', 100, 22, 15000.00, 'RENTA JOSE ANTONIO PELADORA JULIO-SEP'),
('10029', 100, 4, 3000.00, ''),
('1003', 100, 22, 100.00, 'PELADORA (TANG HIELO)'),
('10030', 100, 2, 25000.00, ''),
('10031', 100, 24, 10000.00, ''),
('1004', 100, 22, 1500.00, 'PELADORA (APOYO MANUEL Y ADAN SEMANA NO LABORAL)'),
('1005', 100, 22, 1000.00, 'PELADORA (APOYO MANUEL Y ADAN )'),
('1006', 100, 22, 5000.00, 'PELADORA (APOYO JAVIER SEMANA NO LABORAL)'),
('1007', 100, 22, 500.00, 'PELADORA(PAGO GARRAFON REPARACION ENERGIA ELECT.)'),
('1008', 100, 22, 80.00, 'PELADORA (PAGO FUSIBLE CUCHILLA)'),
('1009', 100, 22, 20000.00, 'PELADORA (PRESTAMO LUIS E TORRES)'),
('1011', 101, 1, 167291.41, ''),
('10110', 101, 22, 506.00, 'PELADORA (COMIDA TOSTON)'),
('10111', 101, 22, 500.00, 'PELADORA (APOYO MACLIN)'),
('10112', 101, 14, 2774.00, ''),
('10113', 101, 16, 200.00, ''),
('10114', 101, 12, 8000.00, ''),
('10115', 101, 22, 250.00, 'NANCY'),
('10116', 101, 26, 100.00, ''),
('10117', 101, 22, 200.00, 'GASOLINA ADRIAN'),
('10118', 101, 22, 200.00, 'GASOLINA MCKLIN'),
('10119', 101, 22, 0.00, 'ABONO PRESTAMO'),
('1012', 101, 3, 13400.00, ''),
('10120', 101, 22, 200.00, 'GASOLINA NOE'),
('10121', 101, 27, 2835.00, ''),
('10122', 101, 17, 1588.00, ''),
('10123', 101, 2, 23625.00, ''),
('10124', 101, 4, 7900.00, ''),
('10125', 101, 24, 18000.00, ''),
('1013', 101, 22, 160.00, 'PELADORA (POZOL HIELO PERSONAL)'),
('1014', 101, 22, 2500.00, 'PELADORA(CONTROL PLAGAS TOSTON)'),
('1015', 101, 22, 103055.00, 'PELADORA (PAGO FERTILIZANTES)'),
('1016', 101, 22, 350.00, 'PELADORA (PRODUCTO PARA LIMPIEZA Y DESINFECCION)'),
('1017', 101, 22, 2500.00, 'PELADORA (CUBREBOCAS PERSONAL)'),
('1018', 101, 22, 200.00, 'PELADORA (PAGO REPARACION CARRETA)'),
('1019', 101, 22, 100.00, 'PELADORA (REVISION DE MINI SPLIT GARRAFON)'),
('1021', 102, 1, 199088.41, ''),
('10210', 102, 22, 300.00, 'APOYO ALEXIS ENFERMEDAD'),
('10211', 102, 22, 300.00, 'REPARACION MALLA EZEQUIEL HERRERO'),
('10212', 102, 22, 1000.00, 'APOYO MACLIN '),
('10213', 102, 22, 1000.00, 'APOYO ADAN Y MANUEL'),
('10214', 102, 22, 36.00, 'LIBRETA Y LAPICERO'),
('10215', 102, 22, 3600.00, 'TECNICO COATZA'),
('10216', 102, 14, 2774.00, ''),
('10217', 102, 16, 200.00, ''),
('10218', 102, 22, 512.00, 'ENERIA ELECTRICA PELADORA TOSTON'),
('10219', 102, 12, 8000.00, ''),
('1022', 102, 3, 14300.00, ''),
('10220', 102, 22, 100.00, 'NANCY'),
('10221', 102, 26, 100.00, ''),
('10222', 102, 22, 200.00, 'GASOLINA ADRIAN'),
('10223', 102, 22, 200.00, 'GASOLINA MCKLIN'),
('10224', 102, 22, 200.00, 'GASOLINA NOE'),
('10225', 102, 22, 42.00, 'APP JOSE'),
('10226', 102, 27, 2868.00, ''),
('10227', 102, 17, 1600.00, ''),
('10228', 102, 4, 1500.00, ''),
('10229', 102, 2, 23900.00, ''),
('1023', 102, 22, 180.00, 'PELADORA (POZOL HIELO PERSONAL)'),
('1024', 102, 22, 98.00, 'PELADORA (MARCADORES PARA PELADORA )'),
('1025', 102, 22, 880.00, 'NEBULIZADOR'),
('1026', 102, 22, 1440.00, 'OXIMETRO'),
('1027', 102, 22, 350.00, 'MEDICAMENTO NEBULIZACION'),
('1028', 102, 22, 600.00, 'APOYO GLORIA E HIJA PELADORA ENFERMEDAD'),
('1029', 102, 22, 340.00, 'APOYO DANIEL ENFERMEDAD'),
('1031', 103, 1, 191614.70, ''),
('10310', 103, 16, 200.00, ''),
('10311', 103, 22, 5625.00, 'ENERIA ELECTRICA PELADORA '),
('10312', 103, 12, 8000.00, ''),
('10313', 103, 22, 250.00, 'NANCY'),
('10314', 103, 26, 100.00, ''),
('10315', 103, 22, 200.00, 'GASOLINA ADRIAN'),
('10316', 103, 22, 200.00, 'GASOLINA MCKLIN'),
('10317', 103, 22, 200.00, 'GASOLINA NOE'),
('10318', 103, 27, 2937.00, ''),
('10319', 103, 17, 1570.00, ''),
('1032', 103, 3, 13900.00, ''),
('10320', 103, 4, 1500.00, ''),
('10321', 103, 2, 24475.00, ''),
('1033', 103, 22, 150.00, 'POZOL HIELO PERSONAL'),
('1034', 103, 22, 100.00, 'MARCADORES PARA PELADORA '),
('1035', 103, 22, 500.00, 'PAGO GARRAFON REPARACION E.E.P'),
('1036', 103, 22, 100.00, 'PAGO FUSIBLE REPARACION E.E.P'),
('1037', 103, 22, 544.00, 'MEDICAMENTOS JAVIER'),
('1038', 103, 22, 114.00, 'PILA PARA TERMOMETRO INFRAROJO'),
('1039', 103, 14, 2774.00, ''),
('1041', 104, 1, 190771.50, ''),
('10410', 104, 12, 8000.00, ''),
('10411', 104, 22, 250.00, 'NANCY'),
('10412', 104, 26, 100.00, ''),
('10413', 104, 22, 200.00, 'GASOLINA ADRIAN'),
('10414', 104, 22, 200.00, 'GASOLINA MCKLIN'),
('10415', 104, 22, 200.00, 'GASOLINA NOE'),
('10416', 104, 22, 20000.00, 'RENTA TOSTON AGOSTO'),
('10417', 104, 15, 8500.00, ''),
('10418', 104, 22, 8500.00, 'APP JOSE'),
('10419', 104, 27, 2961.00, ''),
('1042', 104, 3, 12200.00, ''),
('10420', 104, 17, 1380.00, ''),
('10421', 104, 4, 1500.00, ''),
('10422', 104, 2, 24675.00, ''),
('1043', 104, 22, 170.00, 'POZOL HIELO PERSONAL'),
('1044', 104, 22, 22539.26, 'GUANTES PERSONAL'),
('1045', 104, 22, 422.00, 'INTERNET TOSTON'),
('1046', 104, 22, 411.00, 'INTERNET PELADORA '),
('1047', 104, 22, 300.00, 'REPARACION DE DOS LLANTAS DE NISSAN'),
('1048', 104, 14, 2774.00, ''),
('1049', 104, 16, 200.00, ''),
('1051', 105, 1, 167186.34, ''),
('10510', 105, 22, 0.00, 'BOLSAS  COMPRA'),
('10511', 105, 12, 8000.00, ''),
('10512', 105, 22, 250.00, 'NANCY'),
('10513', 105, 26, 100.00, ''),
('10514', 105, 5, 51393.36, ''),
('10515', 105, 22, 200.00, 'GASOLINA ADRIAN'),
('10516', 105, 22, 200.00, 'GASOLINA MCKLIN'),
('10517', 105, 13, 10000.00, ''),
('10518', 105, 22, 200.00, 'GASOLINA NOE'),
('10519', 105, 22, 0.00, 'ABONO FUNGICIDA'),
('1052', 105, 3, 11700.00, ''),
('10520', 105, 22, 0.00, 'ABONO FERTILIZANTE'),
('10521', 105, 27, 2985.00, ''),
('10522', 105, 17, 1430.00, ''),
('10523', 105, 4, 1500.00, ''),
('10524', 105, 2, 24875.00, ''),
('10525', 105, 29, 11068.75, ''),
('10526', 105, 23, 12881.88, ''),
('1053', 105, 22, 150.00, 'POZOL HIELO PERSONAL'),
('1054', 105, 22, 1000.00, 'APOYO MANUEL Y ADAN'),
('1055', 105, 22, 240.00, 'GEL ANTIBACTERIAL Y JABON PARA MANOS'),
('1056', 105, 22, 90.00, 'ESCOBA Y TRAPEADOR PARA CONTENEDOR'),
('1057', 105, 22, 1190.00, 'ETIQUETAS PARA BOLSAS'),
('1058', 105, 14, 2774.00, ''),
('1059', 105, 16, 200.00, ''),
('1061', 106, 1, 179548.11, ''),
('10610', 106, 22, 500.00, '  GARRAFON TRABAJO ELECTRICIDAD TOSTON'),
('10611', 106, 22, 1000.00, '2 REPARACIONES E.E CONTENEDOR '),
('10612', 106, 22, 200.00, 'PAGO DE FUSIBLES PARA REPARACION EE '),
('10613', 106, 22, 300.00, 'REPARACION CARRETA PARA BAJAR FRUTA'),
('10614', 106, 14, 2774.00, ''),
('10615', 106, 16, 200.00, ''),
('10616', 106, 12, 8000.00, ''),
('10617', 106, 22, 250.00, 'NANCY'),
('10618', 106, 26, 100.00, ''),
('10619', 106, 22, 200.00, 'GASOLINA ADRIAN'),
('1062', 106, 3, 13400.00, ''),
('10620', 106, 22, 200.00, 'GASOLINA MCKLIN'),
('10621', 106, 22, 200.00, 'GASOLINA NOE'),
('10622', 106, 22, 0.00, 'ABONO FUNGICIDA'),
('10623', 106, 22, 0.00, 'ABONO FERTILIZANTE'),
('10624', 106, 27, 2919.00, ''),
('10625', 106, 17, 2280.00, ''),
('10626', 106, 4, 8200.00, ''),
('10627', 106, 2, 24325.00, ''),
('10628', 106, 29, 4277.08, ''),
('10629', 106, 23, 10771.71, ''),
('1063', 106, 22, 200.00, 'POZOL HIELO PERSONAL'),
('1064', 106, 22, 1176.35, 'PAQUETERIA GUANTES'),
('1065', 106, 22, 1000.00, 'APOYO MANUEL Y ADAN'),
('1066', 106, 22, 875.00, 'CARRETILLA PARA DESCARGA DE FRUTA'),
('1067', 106, 22, 577.77, 'VERNIER (PATA DE REY)'),
('1068', 106, 22, 41715.00, 'FERTILIZANTE PRODUCTORES'),
('1069', 106, 22, 480.00, 'COMIDA TOSTON (2 DIAS)'),
('1071', 107, 1, 171646.27, ''),
('10710', 107, 22, 100.00, 'PAGO GARRAFON CAJA PARA CORTE'),
('10711', 107, 22, 300.00, 'COMIDA BOLSEROS DIA DE CARGA'),
('10712', 107, 22, 6280.00, 'FERTILIZANTE NAIN PEREZ'),
('10713', 107, 22, 7000.00, 'CORTINA DE AIRE PARA PUERTA CONTENEDOR'),
('10714', 107, 16, 2974.00, ''),
('10715', 107, 12, 8000.00, ''),
('10716', 107, 22, 250.00, 'NANCY'),
('10717', 107, 26, 100.00, ''),
('10718', 107, 22, 200.00, 'GASOLINA ADRIAN'),
('10719', 107, 22, 200.00, 'GASOLINA MCKLIN'),
('1072', 107, 3, 11500.00, ''),
('10720', 107, 13, 38.00, ''),
('10721', 107, 22, 200.00, 'GASOLINA NOE'),
('10722', 107, 22, 0.00, 'ABONO FUNGICIDA'),
('10723', 107, 22, 0.00, 'ABONO FERTILIZANTE'),
('10724', 107, 9, 7124.00, ''),
('10725', 107, 27, 2898.00, ''),
('10726', 107, 17, 1970.00, ''),
('10727', 107, 2, 24150.00, ''),
('10728', 107, 4, 6250.00, ''),
('10729', 107, 29, 7377.53, ''),
('1073', 107, 22, 1000.00, 'APOYO MANUEL Y ADAN'),
('10730', 107, 23, 13440.33, ''),
('1074', 107, 22, 280.00, 'COMIDA TOSTON'),
('1075', 107, 22, 150.00, 'TRABAJO HERRAMIENTA METAL TOSTON'),
('1076', 107, 22, 250.00, 'HERRAMIENTA MADERA TOSTON'),
('1077', 107, 22, 741.00, 'CUCHILLOS PARA HERRAMIENTA'),
('1078', 107, 22, 1600.00, 'CAJA ELECTRICA TOSTON'),
('1079', 107, 22, 500.00, 'PAGO GARRAFON CAMBIO CAJA TOSTON'),
('1081', 108, 1, 175174.56, ''),
('10810', 108, 14, 2774.00, ''),
('10811', 108, 16, 200.00, ''),
('10812', 108, 13, 8000.00, ''),
('10813', 108, 22, 250.00, 'NANCY'),
('10814', 108, 26, 100.00, ''),
('10815', 108, 22, 200.00, 'GASOLINA ADRIAN'),
('10816', 108, 22, 200.00, 'GASOLINA MCKLIN'),
('10817', 108, 22, 200.00, 'GASOLINA NOE'),
('10818', 108, 22, 0.00, 'ABONO FUNGICIDA'),
('10819', 108, 22, 0.00, 'ABONO FERTILIZANTE'),
('1082', 108, 3, 12200.00, ''),
('10820', 108, 27, 3066.00, ''),
('10821', 108, 17, 1630.00, ''),
('10822', 108, 2, 25550.00, ''),
('10823', 108, 4, 1500.00, ''),
('10824', 108, 29, 5691.96, ''),
('10825', 108, 23, 16088.67, ''),
('1083', 108, 22, 190.00, 'POZOL HIELO PARA PERSONAL'),
('1084', 108, 22, 325.00, 'MATERIAL PARA PISO CONTENEDOR CARGA'),
('1085', 108, 22, 300.00, 'APOYO DOÑA CHUCHITA'),
('1086', 108, 22, 400.00, 'PAGO NOE PISO CONTENEDOR CARGA'),
('1087', 108, 22, 10749.72, 'COMPRA 4 LLANTAS CAMIONETA NISSAN'),
('1088', 108, 22, 500.00, 'MARCO PARA CORTINA DE AIRE CONTENEDOR'),
('1089', 108, 22, 1100.00, 'SERVICIO AFINACION CAMIONETA NISSAN'),
('1091', 109, 1, 176010.69, ''),
('10910', 109, 22, 1000.00, 'APOYO MANUEL Y ADAN'),
('10911', 109, 14, 2774.00, ''),
('10912', 109, 16, 200.00, ''),
('10913', 109, 12, 8000.00, ''),
('10914', 109, 22, 250.00, 'NANCY'),
('10915', 109, 26, 100.00, ''),
('10916', 109, 22, 200.00, 'GASOLINA   ADRIAN'),
('10917', 109, 22, 200.00, 'GASOLINA   MCKLIN'),
('10918', 109, 13, 6500.00, ''),
('10919', 109, 7, 20000.00, ''),
('1092', 109, 3, 12150.00, ''),
('10920', 109, 22, 200.00, 'GASOLINA NOE'),
('10921', 109, 15, 8500.00, ''),
('10922', 109, 26, 3048.00, ''),
('10923', 109, 17, 1350.00, ''),
('10924', 109, 18, 200.00, ''),
('10925', 109, 4, 1500.00, ''),
('10926', 109, 2, 25400.00, ''),
('10927', 109, 29, 7386.69, ''),
('10928', 109, 23, 14516.41, ''),
('1093', 109, 22, 240.00, 'POZOL HIELO PARA PERSONAL'),
('1094', 109, 22, 4180.00, 'CAMBIO DE PIEZAS DE CAMIONETA PARA ALINEACION DE L'),
('1095', 109, 22, 31160.00, 'FERTILIZANTE PRODUCTORES (PALMA-CIRILO)'),
('1096', 109, 22, 8000.00, 'CORTINA DE AIRE PARA CONTENEDOR PELADORA'),
('1097', 109, 22, 120.00, 'MARCADORES Y LIBRETA PARA PELADORA'),
('1098', 109, 22, 695.00, 'PIEZA PARA COMPUTADORA'),
('1099', 109, 22, 950.00, 'MANTENIMIENTO EQUIPO DE COMPUTO'),
('1101', 110, 1, 170477.89, ''),
('11010', 110, 22, 4502.65, 'CARGA DE GAS TOSTON'),
('11011', 110, 22, 460.00, 'COMIDA TOSTON'),
('11012', 110, 14, 2774.00, ''),
('11013', 110, 16, 200.00, ''),
('11014', 110, 12, 10000.00, ''),
('11015', 110, 22, 250.00, 'NANCY'),
('11016', 110, 26, 100.00, ''),
('11017', 110, 22, 200.00, 'GASOLINA ADRIAN'),
('11018', 110, 22, 200.00, 'GASOLINA MCKLIN'),
('11019', 110, 13, 41.00, ''),
('1102', 110, 3, 10700.00, ''),
('11020', 110, 22, 200.00, 'GASOLINA NOE'),
('11021', 110, 22, 0.00, 'ABONO FUNGICIDA'),
('11022', 110, 22, 0.00, 'ABONO FERTILIZANTE'),
('11023', 110, 27, 2952.00, ''),
('11024', 110, 17, 2040.00, ''),
('11025', 110, 18, 300.00, ''),
('11026', 110, 4, 7500.00, ''),
('11027', 110, 2, 24600.00, ''),
('11028', 110, 29, 5020.01, ''),
('11029', 110, 23, 17896.13, ''),
('1103', 110, 22, 150.00, 'POZOL HIELO PARA PERSONAL'),
('1104', 110, 22, 180.00, 'MATERIAL PARA INSTALAR CORTINA PELADORA'),
('1105', 110, 22, 500.00, 'PAGO GARRAFON INSTALACION CORTINA'),
('1106', 110, 22, 600.00, '4 HERRAMIENTAS PARA CORTE DE PLATANO TOSTON'),
('1107', 110, 22, 250.00, 'LIMPIA PARABRISAS CAMIONETA NISSAN'),
('1108', 110, 22, 480.00, 'COMPRA DE GUANTES PARA TOSTON'),
('1109', 110, 22, 240.00, 'COMPRA PALA PARA PELADORA '),
('1111', 111, 1, 175905.80, ''),
('11110', 111, 16, 200.00, ''),
('11111', 111, 12, 8000.00, ''),
('11112', 111, 22, 250.00, 'NANCY'),
('11113', 111, 26, 100.00, ''),
('11114', 111, 22, 200.00, 'GASOLINA ADRIAN'),
('11115', 111, 22, 200.00, 'GASOLINA MCKLIN'),
('11116', 111, 13, 600.00, ''),
('11117', 111, 9, 6320.00, ''),
('11118', 111, 22, 200.00, 'GASOLINA NOE'),
('11119', 111, 11, 1208.00, ''),
('1112', 111, 3, 12000.00, ''),
('11120', 111, 27, 3015.00, ''),
('11121', 111, 17, 1940.00, ''),
('11122', 111, 4, 1500.00, ''),
('11123', 111, 2, 25125.00, ''),
('11124', 111, 29, 5032.60, ''),
('11125', 111, 23, 14807.81, ''),
('1113', 111, 22, 1000.00, 'APOYO MANUEL Y ADAN'),
('1114', 111, 22, 150.00, 'POZOL HIELO PARA PERSONAL'),
('1115', 111, 22, 13511.20, 'COMPRA LAP TOP'),
('1116', 111, 22, 1350.00, 'ETIQUETAS PELADORA'),
('1117', 111, 22, 740.00, 'CABLE ADAPTADOR HDMI'),
('1118', 111, 22, 1150.00, 'CUBREBOCAS KN95 Y CARETAS DE PROTECCION'),
('1119', 111, 14, 2774.00, ''),
('1121', 112, 1, 175068.12, ''),
('11210', 112, 22, 500.00, 'PAGO CHOFER DE LUIS '),
('11211', 112, 22, 400.00, 'GASOLINA CAMIONETA LUIS'),
('11212', 112, 22, 3864.00, 'PAGO IMPUESTOS SAT'),
('11213', 112, 14, 2774.00, ''),
('11214', 112, 16, 200.00, ''),
('11215', 112, 12, 8000.00, ''),
('11216', 112, 22, 250.00, 'NANCY'),
('11217', 112, 26, 100.00, ''),
('11218', 112, 22, 200.00, 'GASOLINA ADRIAN'),
('11219', 112, 22, 200.00, 'GASOLINA MCKLIN'),
('1122', 112, 3, 12150.00, ''),
('11220', 112, 22, 200.00, 'GASOLINA NOE'),
('11221', 112, 27, 3051.00, ''),
('11222', 112, 17, 1940.00, ''),
('11223', 112, 2, 25425.00, ''),
('11224', 112, 4, 1500.00, ''),
('11225', 112, 29, 5044.05, ''),
('11226', 112, 23, 18568.63, ''),
('11227', 112, 22, 798.00, 'PAGO INTERNET DE PELADORA'),
('11228', 112, 22, 352.00, 'PAGO INTERNET DE TOSTON'),
('1123', 112, 22, 400.00, 'PAGO GARRAFON RECORRIDO LINEA ELECTRICA'),
('1124', 112, 22, 300.00, 'POZOL HIELO PARA PERSONAL'),
('1125', 112, 22, 780.00, 'TERMOMETRO'),
('1126', 112, 22, 980.00, 'TERMOMETRO PARA ACEITE'),
('1127', 112, 22, 1500.00, 'RENTA CAMARA FRIA'),
('1128', 112, 22, 33700.00, 'PAGO FUNGICIDA PARA PRODUCTORES'),
('1129', 112, 22, 400.00, 'VIGILANCIA CAMARA NOE'),
('1131', 113, 1, 194554.00, ''),
('11310', 113, 12, 8000.00, ''),
('11311', 113, 22, 0.00, 'NANCY'),
('11312', 113, 26, 100.00, ''),
('11313', 113, 22, 0.00, 'GASOLINA ADRIAN'),
('11314', 113, 22, 0.00, 'GASOLINA MCKLIN'),
('11315', 113, 13, 10000.00, ''),
('11316', 113, 9, 0.00, ''),
('11317', 113, 22, 0.00, 'GASOLINA NOE'),
('11318', 113, 11, 0.00, ''),
('11319', 113, 27, 2640.00, ''),
('1132', 113, 3, 10600.00, ''),
('11320', 113, 17, 3808.00, ''),
('11321', 113, 2, 22000.00, ''),
('11322', 113, 4, 20100.00, ''),
('11323', 113, 6, 15000.00, ''),
('11324', 113, 7, 20000.00, ''),
('11325', 113, 8, 6500.00, ''),
('11326', 113, 15, 8500.00, ''),
('11327', 113, 18, 550.00, ''),
('11328', 113, 30, 850.00, ''),
('11329', 113, 22, 250.00, 'REFRESCO GALLESTAS'),
('1133', 113, 22, 0.00, 'POZOL HIELO PARA PERSONAL'),
('11330', 113, 22, 525.00, 'VERNIER DIGITAL'),
('11331', 113, 22, 2150.00, 'ACEITE DE PALMA'),
('11332', 113, 22, 3750.00, 'TEGNICO TOSTON'),
('11333', 113, 22, 4418.00, 'PAGO IMPUESTOS MAYO-JUNIO'),
('1134', 113, 22, 0.00, 'TERMOMETRO'),
('1135', 113, 22, 0.00, 'TERMOMETRO PARA ACEITE'),
('1136', 113, 22, 0.00, 'RENTA CAMARA FRIA'),
('1137', 113, 22, 0.00, 'PAGO FUNGICIDA PARA PRODUCTORES'),
('1138', 113, 14, 2774.00, ''),
('1139', 113, 16, 200.00, ''),
('1141', 114, 1, 186483.19, ''),
('11410', 114, 27, 2886.00, ''),
('11411', 114, 26, 100.00, ''),
('11412', 114, 30, 850.00, ''),
('11413', 114, 22, 215.00, 'CAFE, GALLETAS, VASOS'),
('11414', 114, 22, 1300.00, 'TECNICO TOSTON'),
('11415', 114, 22, 3000.00, 'DESPALOTADA GARRAFON'),
('11416', 114, 22, 1000.00, 'HERRAMIENTAS CORTES TOSTON'),
('11417', 114, 22, 1200.00, 'PAGO TECNICO TOSTON'),
('11418', 114, 22, 250.00, 'COMIDA TOSTON GERSON'),
('11419', 114, 22, 8500.00, 'COMPRA ACEITE TOSTON'),
('1142', 114, 3, 11900.00, ''),
('11420', 114, 22, 500.00, 'PAGO GARRAFON REPARACION LUZ'),
('11421', 114, 22, 3800.00, 'REPARACION GOTERAS'),
('11422', 114, 22, 250.00, 'JOSE ANTONIO VIAJE A VILLAHERMOSA'),
('11423', 114, 22, 500.00, 'APOYO A DOÑA CHUCHITA'),
('11424', 114, 22, 310.00, 'COMIDA GARRAFON VILLA'),
('11425', 114, 22, 1000.00, 'APOYO A MANUEL Y ADAN'),
('1143', 114, 4, 6500.00, ''),
('1144', 114, 2, 24050.00, ''),
('1145', 114, 12, 8000.00, ''),
('1146', 114, 13, 1050.33, ''),
('1147', 114, 14, 2774.00, ''),
('1148', 114, 16, 200.00, ''),
('1149', 114, 17, 2142.00, ''),
('1151', 115, 1, 193273.80, ''),
('11510', 115, 30, 850.00, ''),
('11511', 115, 26, 100.00, ''),
('11512', 115, 22, 150.00, 'REFRESCO PERSONAL'),
('11513', 115, 22, 2017.00, 'PAGOS SAT (JULIO)'),
('11514', 115, 22, 2091.00, 'PAGOS SAT (AGOSTO)'),
('11515', 115, 22, 1999.00, 'IMPRESORA'),
('11516', 115, 22, 650.00, 'PAGO A GARRAFON CAMBIO CLAVIJAS'),
('11517', 115, 22, 6000.00, 'COMPRA METRIAL PISO CONTENEDOR'),
('11518', 115, 22, 700.00, 'CAMBIO 2 CALABERAS NISSAN'),
('11519', 115, 22, 100.00, 'LIQUIDO DE FRENOS PARA NISSAN'),
('1152', 115, 4, 3100.00, ''),
('11520', 115, 22, 300.00, 'COMIDA BOLSEROS DIA CARGA'),
('11521', 115, 22, 200.00, 'CORTE DE REJILLA DE METAL BOLSAS'),
('11522', 115, 2, 25275.00, ''),
('1153', 115, 3, 13700.00, ''),
('1154', 115, 12, 8000.00, ''),
('1155', 115, 13, 2600.00, ''),
('1156', 115, 14, 2774.00, ''),
('1157', 115, 16, 200.00, ''),
('1158', 115, 17, 1940.00, ''),
('1159', 115, 27, 3033.00, ''),
('1161', 116, 4, 4800.00, ''),
('11610', 116, 17, 2742.00, ''),
('11611', 116, 27, 3033.00, ''),
('11612', 116, 30, 850.00, ''),
('11613', 116, 26, 100.00, ''),
('11614', 116, 22, 1044.94, 'MATERIAL ALBAñIL SANTANDREU'),
('11615', 116, 22, 108000.00, 'EQUIPO PARA CONTENEDOR Y MANO DE OBRA'),
('11616', 116, 22, 1045.00, 'RESTAURANTE EL PUCHERO REUNION CONTADOR'),
('11617', 116, 22, 326.00, 'DISCO PARA CONCRETO TRABAJO TOSTON'),
('11618', 116, 22, 5729.00, 'COMPRA SILVA VILLAHERMOSA '),
('11619', 116, 22, 116.53, 'COMPRA SILVA VILLAHERMOSA'),
('1162', 116, 3, 11500.00, ''),
('11620', 116, 22, 5500.00, 'MATERIAL DE OBRA ALBAñIL TRABAJO PELADORA'),
('11621', 116, 22, 2500.00, 'INSTALACIPON ELECTRICA GARRAFON'),
('11622', 116, 22, 300.00, 'TRABAJO HERRERO'),
('11623', 116, 22, 390.00, 'MATERIAL HERRERO'),
('11624', 116, 22, 360.00, 'TUBULAR PAGO TECHO'),
('11625', 116, 22, 696.00, 'LAMINA Y PIJA PARA LAMINA'),
('11626', 116, 22, 100.00, 'GASOLINA ARMANDO'),
('11627', 116, 22, 46.00, 'COCA-COLA HERRERO'),
('11628', 116, 22, 1281.92, 'TUBO GALVANIZADO'),
('11629', 116, 22, 500.00, 'BLOCKS'),
('1163', 116, 1, 196513.12, ''),
('11630', 116, 22, 317.00, 'ARENA GRAVA'),
('11631', 116, 22, 5661.00, 'MATERIAL ALBAñIL PISO Y BARRAS PARA CONTENEDOR'),
('1164', 116, 2, 25276.00, ''),
('1165', 116, 9, 7591.00, ''),
('1166', 116, 12, 8000.00, ''),
('1167', 116, 14, 2774.00, ''),
('1168', 116, 16, 200.00, ''),
('1169', 116, 18, 841.00, ''),
('1171', 117, 1, 197924.02, ''),
('11710', 117, 27, 3045.00, ''),
('11711', 117, 25, 850.00, ''),
('11712', 117, 26, 100.00, ''),
('11713', 117, 22, 2000.00, 'PAGO HERRERO'),
('11714', 117, 22, 3000.00, 'MATERIAL HERRERO'),
('11715', 117, 22, 500.00, 'APOYO A CHUCHITA'),
('11716', 117, 22, 3600.00, 'TECNICO CONTENEDOR COATZA'),
('11717', 117, 22, 800.00, 'LIMPIEZA CASCARA PELADORA'),
('11718', 117, 22, 800.00, 'TRABAJO COLAERA TOSTON'),
('11719', 117, 22, 640.00, 'MATERIAL TRABAJO COLADERA TOSTON'),
('1172', 117, 2, 25375.00, ''),
('11720', 117, 22, 4500.00, 'FINIQUITO MISAEL BOLSERO'),
('11721', 117, 22, 2486.00, 'MATERIAL PARA CERCA EQUIPO ENFRIAMIENTO'),
('11722', 117, 22, 12400.00, 'FINIQUITO EQUIPO ENFRIAMIENTO'),
('11723', 117, 22, 4186.28, 'PAGO TERMOGRAFOS'),
('11724', 117, 22, 230.00, 'CAFE, AZUCAR, GALLETAS Y VASOS '),
('11725', 117, 22, 300.00, 'FORMATEO DE COMPUTADORA INSTALARC. PROGS. '),
('11726', 117, 5, 49880.00, ''),
('1173', 117, 4, 2400.00, ''),
('1174', 117, 3, 12000.00, ''),
('1175', 117, 12, 8000.00, ''),
('1176', 117, 14, 2774.00, ''),
('1177', 117, 15, 10000.00, ''),
('1178', 117, 16, 200.00, ''),
('1179', 117, 17, 1816.00, ''),
('1181', 118, 1, 199466.62, ''),
('11810', 118, 22, 700.00, 'PAGO NOE Y MANUEL'),
('11811', 118, 22, 200.00, 'APOYO A TECNICOS'),
('11812', 118, 22, 2356.60, 'COMPRA HOME DEPOT'),
('11813', 118, 22, 501.60, 'COMIDA CON JOSE VILLAHERMOSA'),
('11814', 118, 22, 300.00, 'GASOLINA CAMIONETA GERSON'),
('11815', 118, 22, 250.00, 'GASOLINA JOSE ANTONIO'),
('11816', 118, 6, 15000.00, ''),
('11817', 118, 7, 20000.00, ''),
('11818', 118, 8, 6500.00, ''),
('11819', 118, 12, 8000.00, ''),
('1182', 118, 2, 24200.00, ''),
('11820', 118, 13, 10000.00, ''),
('11821', 118, 14, 2774.00, ''),
('11822', 118, 17, 1126.00, ''),
('11823', 118, 27, 2904.00, ''),
('11824', 118, 30, 850.00, ''),
('11825', 118, 26, 100.00, ''),
('1183', 118, 3, 12000.00, ''),
('1184', 118, 4, 1500.00, ''),
('1185', 118, 22, 900.00, 'LIMPIEZA PELADORA'),
('1186', 118, 22, 250.00, 'PAN PELADORA'),
('1187', 118, 22, 146580.00, 'PAGO DE FERTILIZANTE'),
('1188', 118, 22, 400.00, 'PEGADO DE BLOCK CONTENEDOR NOE'),
('1189', 118, 22, 500.00, 'MATERIAL PISO, PUERTA CONTENEDOR'),
('1191', 119, 1, 197180.70, ''),
('11910', 119, 22, 325.00, 'BOLSAS DE HIELO EN GEL'),
('11911', 119, 22, 1500.00, 'PAGO A ARMANDO TOSTON'),
('11912', 119, 22, 2000.00, 'APOYO A JAVIER'),
('11913', 119, 22, 512.60, 'COMIDA TOKS VILLAHERMOSA'),
('11914', 119, 22, 600.00, 'GASOLINA CAMIONETA BISMAR'),
('11915', 119, 22, 740.57, 'PAQUETERIA MERIDA'),
('11916', 119, 22, 200.00, 'REMBOLSO FERNANDO TAXI'),
('11917', 119, 22, 300.00, 'GASOLINA CAMIONETA GERSON'),
('11918', 119, 22, 78.00, 'COMPRA MARCADORES PELADORA'),
('11919', 119, 9, 5160.00, ''),
('1192', 119, 4, 1500.00, ''),
('11920', 119, 11, 1334.00, ''),
('11921', 119, 12, 8000.00, ''),
('11922', 119, 13, 16792.97, ''),
('11923', 119, 14, 2774.00, ''),
('11924', 119, 16, 200.00, ''),
('11925', 119, 18, 1400.00, ''),
('11926', 119, 19, 1500.00, ''),
('11927', 119, 27, 2967.00, ''),
('11928', 119, 30, 850.00, ''),
('11929', 119, 26, 100.00, ''),
('1193', 119, 3, 10850.00, ''),
('11930', 119, 2, 24725.00, ''),
('1194', 119, 22, 300.00, 'GASOLINA CAMIONETA LUIS E'),
('1195', 119, 22, 559.90, 'COMIDA ALTABRISA'),
('1196', 119, 22, 1500.00, 'APOYO A MANUEL, MANUEL, BETO'),
('1197', 119, 22, 6500.00, 'SEGUNDO PAGO PROGRAMA PELADORA'),
('1198', 119, 22, 12500.00, 'PAGO RESINA PRODUCTORES'),
('1199', 119, 22, 495.70, 'COMIDA TOKS VILLAHERMOSA'),
('1201', 120, 1, 201676.44, ''),
('12010', 120, 27, 3027.00, ''),
('12011', 120, 30, 850.00, ''),
('12012', 120, 26, 100.00, ''),
('12013', 120, 22, 120.00, 'POZOL, VASOS'),
('12014', 120, 22, 400.00, 'CERRADURA CONTENEDOR (HERRERO)'),
('12015', 120, 22, 400.00, 'APOYO CHUCHITA'),
('12016', 120, 22, 200.00, 'APOYO TRANSPORTE PROGRAMADORES'),
('12017', 120, 22, 160.00, 'COMPRA TECLADO PARA COMPUTADPRA'),
('12018', 120, 22, 1684.00, 'PAGO SAT SEPTIEMBRE'),
('12019', 120, 22, 1870.00, 'PAGO SAT OCTUBRE'),
('1202', 120, 2, 25225.00, ''),
('12020', 120, 22, 50.00, 'CLOTO, JABON'),
('1203', 120, 3, 11300.00, ''),
('1204', 120, 4, 1500.00, ''),
('1205', 120, 12, 8000.00, ''),
('1206', 120, 14, 2774.00, ''),
('1207', 120, 16, 200.00, ''),
('1208', 120, 18, 750.00, ''),
('1209', 120, 19, 1500.00, ''),
('1211', 121, 1, 197089.12, ''),
('12110', 121, 16, 200.00, ''),
('12111', 121, 18, 800.00, ''),
('12112', 121, 19, 1500.00, ''),
('12113', 121, 27, 2841.00, ''),
('12114', 121, 22, 335.00, 'JABON, CLORO'),
('12115', 121, 30, 850.00, ''),
('12116', 121, 26, 100.00, ''),
('1212', 121, 4, 1500.00, ''),
('1213', 121, 3, 11000.00, ''),
('1214', 121, 2, 23675.00, ''),
('1215', 121, 7, 20000.00, ''),
('1216', 121, 8, 6500.00, ''),
('1217', 121, 12, 8000.00, ''),
('1218', 121, 14, 2774.00, ''),
('1219', 121, 15, 10000.00, ''),
('771', 77, 1, 181386.59, ''),
('7710', 77, 13, 8577.00, ''),
('7711', 77, 22, 500.00, 'CAMIONETA JOSE ANTONIO'),
('7712', 77, 5, 24865.10, ''),
('7713', 77, 22, 955.00, 'GUANTES'),
('7714', 77, 22, 500.00, 'GASOLINA NISSAN VISITA DE CAMPO'),
('7715', 77, 22, 600.00, 'GASOLINA BOLSAS TEAPA'),
('7716', 77, 22, 500.00, 'APOYO CHUCHITA'),
('7717', 77, 22, 300.00, 'GASOLINA ANTONIO LECHUGAL'),
('7718', 77, 22, 955.00, 'GUANTES'),
('7719', 77, 22, 3600.00, 'TECNICO CONTENEDOR COATZA'),
('772', 77, 29, 7375.00, ''),
('7720', 77, 22, 400.00, 'GASOLINA NISSAN  TRANSPORTE PERSONAL GUIA'),
('7721', 77, 22, 100.00, 'GAS MUESTRAS WILIAN'),
('7722', 77, 27, 2763.00, ''),
('773', 77, 3, 11250.00, ''),
('774', 77, 2, 23025.00, ''),
('775', 77, 14, 2774.00, ''),
('776', 77, 16, 200.00, ''),
('777', 77, 12, 8000.00, ''),
('778', 77, 22, 250.00, 'NANCY'),
('779', 77, 26, 100.00, ''),
('781', 78, 1, 180568.80, ''),
('7810', 78, 22, 200.00, 'GASOLINA NOE'),
('7811', 78, 22, 200.00, 'GASOLINA MCKLIN'),
('7812', 78, 22, 200.00, 'GASOLINA ADRINA'),
('7813', 78, 27, 2709.00, ''),
('7814', 78, 22, 500.00, 'CAMIONETA JOSE ANTONIO'),
('7815', 78, 9, 10638.00, ''),
('7816', 78, 22, 955.00, 'GUANTES'),
('7817', 78, 22, 50.00, 'ACEITE MUESTRAS WILIAN'),
('7818', 78, 22, 700.00, 'GASOLINA NISSAN'),
('7819', 78, 22, 616.90, 'GUANTES'),
('782', 78, 29, 9500.00, ''),
('7820', 78, 22, 300.00, 'GASOLINA CAMIONETA ANTONIO'),
('7821', 78, 22, 500.00, 'APOYO DALILA RADIOGRAFIA'),
('7822', 78, 22, 1340.00, 'REPARACION NISSAN (BALEROS Y BALATAS DEL)'),
('7823', 78, 22, 1500.00, 'PAGO ARMANDO'),
('783', 78, 3, 10900.00, ''),
('784', 78, 2, 22575.00, ''),
('785', 78, 14, 2774.00, ''),
('786', 78, 16, 200.00, ''),
('787', 78, 12, 8000.00, ''),
('788', 78, 22, 250.00, 'NANCY'),
('789', 78, 26, 100.00, ''),
('791', 79, 1, 158323.45, ''),
('7910', 79, 20, 101845.00, ''),
('7911', 79, 29, 8325.00, ''),
('7912', 79, 23, 16441.68, ''),
('7913', 79, 15, 3400.00, ''),
('7914', 79, 26, 100.00, ''),
('7915', 79, 22, 200.00, 'GASOLINA   NOE'),
('7916', 79, 22, 200.00, 'GASOLINA   MCKLIN'),
('7917', 79, 22, 200.00, 'GASOLINA ADRIAN'),
('7918', 79, 22, 500.00, 'CAMIONETA JOSE ANTONIO'),
('7919', 79, 22, 300.00, 'GASOLINA ANTONIO (LECHUGAL)'),
('792', 79, 3, 9350.00, ''),
('7920', 79, 22, 1054.00, 'GUANTES'),
('7921', 79, 22, 460.90, 'COMIDA VHSA'),
('7922', 79, 22, 135.00, 'OFICCE MAX PAPELERIA'),
('7923', 79, 22, 350.00, 'GASOLINA NISSAN '),
('7924', 79, 22, 722.84, 'GUANTES'),
('7925', 79, 22, 300.00, 'GASOLINA LECHUGAL ANTONIO'),
('7926', 79, 22, 371.00, 'GASLINA NISSAN '),
('7927', 79, 22, 200.00, 'GUIA'),
('7928', 79, 22, 700.00, 'POLLO REUNION PELADORA'),
('7929', 79, 22, 300.00, 'APOYO CHUCHITA'),
('793', 79, 4, 1500.00, ''),
('7930', 79, 2, 22375.00, ''),
('794', 79, 14, 2774.00, ''),
('795', 79, 16, 200.00, ''),
('796', 79, 12, 8000.00, ''),
('797', 79, 22, 250.00, 'NANCY'),
('798', 79, 13, 16886.80, ''),
('801', 80, 1, 147816.47, ''),
('8010', 80, 22, 4210.00, 'ANEXO GASTOS PELADORA'),
('8011', 80, 29, 7425.00, ''),
('8012', 80, 23, 15755.34, ''),
('8013', 80, 22, 2686.00, 'AGUINALDO E79'),
('8014', 80, 22, 5000.00, 'CARRO JAVIER'),
('8015', 80, 2, 21200.00, ''),
('802', 80, 3, 9330.00, ''),
('803', 80, 14, 2774.00, ''),
('804', 80, 16, 200.00, ''),
('805', 80, 12, 8000.00, ''),
('806', 80, 22, 250.00, 'NANCY'),
('807', 80, 26, 100.00, ''),
('808', 80, 27, 2544.00, ''),
('809', 80, 17, 500.00, ''),
('811', 81, 1, 155771.88, ''),
('8110', 81, 22, 3696.00, 'ANEXO  GASTOS  PELADORA'),
('8111', 81, 29, 6000.00, ''),
('8112', 81, 23, 1298.20, ''),
('8113', 81, 18, 400.00, ''),
('8114', 81, 2, 17925.00, ''),
('812', 81, 3, 10200.00, ''),
('813', 81, 4, 1500.00, ''),
('814', 81, 14, 2774.00, ''),
('815', 81, 16, 200.00, ''),
('816', 81, 22, 250.00, 'NANCY'),
('817', 81, 26, 100.00, ''),
('818', 81, 17, 500.00, ''),
('819', 81, 27, 2151.00, ''),
('821', 82, 1, 170337.62, ''),
('8210', 82, 13, 13000.00, ''),
('8211', 82, 7, 20000.00, ''),
('8212', 82, 29, 8710.00, ''),
('8213', 82, 23, 16238.00, ''),
('8214', 82, 17, 500.00, ''),
('8215', 82, 27, 2868.00, ''),
('8216', 82, 22, 10083.80, 'ANEXO  GASTOS  PELADORA'),
('8217', 82, 2, 23900.00, ''),
('822', 82, 3, 9550.00, ''),
('823', 82, 4, 1500.00, ''),
('824', 82, 14, 2774.00, ''),
('825', 82, 16, 200.00, ''),
('826', 82, 12, 8000.00, ''),
('827', 82, 22, 250.00, 'NANCY'),
('828', 82, 26, 100.00, ''),
('829', 82, 18, 400.00, ''),
('831', 83, 1, 174024.98, ''),
('8310', 83, 13, 6000.00, ''),
('8311', 83, 29, 5180.00, ''),
('8312', 83, 23, 14615.01, ''),
('8313', 83, 17, 500.00, ''),
('8314', 83, 27, 2808.00, ''),
('8315', 83, 9, 9177.00, ''),
('8316', 83, 22, 27849.30, 'ANEXO GASTOS PELADORA'),
('8317', 83, 22, 4300.00, 'ANEXO GASTOS TOSTON'),
('8318', 83, 2, 23400.00, ''),
('832', 83, 3, 11150.00, ''),
('833', 83, 4, 3700.00, ''),
('834', 83, 14, 2774.00, ''),
('835', 83, 15, 8500.00, ''),
('836', 83, 12, 8000.00, ''),
('837', 83, 22, 100.00, 'NANCY'),
('838', 83, 26, 100.00, ''),
('839', 83, 18, 400.00, ''),
('841', 84, 2, 24175.00, ''),
('8410', 84, 26, 100.00, ''),
('8411', 84, 18, 400.00, ''),
('8412', 84, 27, 2901.00, ''),
('8413', 84, 22, 1672.00, 'ANEXO GASTOS PELADORA'),
('8414', 84, 22, 1391.00, 'ANEXO GASTOS TOSTON'),
('842', 84, 1, 179651.73, ''),
('843', 84, 3, 12900.00, ''),
('844', 84, 23, 16442.00, ''),
('845', 84, 29, 905.00, ''),
('846', 84, 4, 3700.00, ''),
('847', 84, 14, 2774.00, ''),
('848', 84, 12, 8000.00, ''),
('849', 84, 22, 250.00, 'NANCY'),
('851', 85, 1, 154263.92, ''),
('8510', 85, 18, 400.00, ''),
('8511', 85, 13, 2500.00, ''),
('8512', 85, 7, 20000.00, ''),
('8513', 85, 29, 900.00, ''),
('8514', 85, 23, 15400.00, ''),
('8515', 85, 27, 2610.00, ''),
('8516', 85, 11, 519.00, ''),
('8517', 85, 22, 4800.00, 'ANEXO  GASTOS  PELADORA'),
('8518', 85, 22, 2345.00, 'ANEXO GASTOS TOSTON'),
('852', 85, 3, 10100.00, ''),
('853', 85, 2, 21750.00, ''),
('854', 85, 4, 6400.00, ''),
('855', 85, 14, 2774.00, ''),
('856', 85, 16, 200.00, ''),
('857', 85, 12, 8000.00, ''),
('858', 85, 22, 250.00, 'NANCY'),
('859', 85, 26, 100.00, ''),
('861', 86, 1, 202467.20, ''),
('8610', 86, 18, 400.00, ''),
('8611', 86, 13, 18000.00, ''),
('8612', 86, 11, 6692.00, ''),
('8613', 86, 29, 1805.00, ''),
('8614', 86, 23, 2031.00, ''),
('8615', 86, 27, 2862.00, ''),
('8616', 86, 22, 9250.00, 'ANEXO GASTOS PELADORA'),
('8617', 86, 22, 1290.00, 'ANEXO GASTOS TOSTON'),
('862', 86, 3, 11300.00, ''),
('863', 86, 2, 23850.00, ''),
('864', 86, 4, 6150.00, ''),
('865', 86, 14, 2774.00, ''),
('866', 86, 16, 200.00, ''),
('867', 86, 12, 8000.00, ''),
('868', 86, 22, 250.00, 'NANCY'),
('869', 86, 26, 100.00, ''),
('871', 87, 1, 176654.09, ''),
('8710', 87, 18, 400.00, ''),
('8711', 87, 13, 18000.00, ''),
('8712', 87, 11, 6692.00, ''),
('8713', 87, 27, 2862.00, ''),
('8714', 87, 22, 9250.00, 'ANEXO GASTOS PELADORA'),
('8715', 87, 22, 1290.00, 'ANEXO GASTOS TOSTON'),
('872', 87, 4, 6150.00, ''),
('873', 87, 3, 11300.00, ''),
('874', 87, 2, 23850.00, ''),
('875', 87, 14, 2774.00, ''),
('876', 87, 16, 200.00, ''),
('877', 87, 12, 8000.00, ''),
('878', 87, 22, 250.00, 'NANCY'),
('879', 87, 26, 100.00, ''),
('881', 88, 1, 185761.59, ''),
('8810', 88, 13, 50000.00, ''),
('8811', 88, 24, 10000.00, ''),
('8812', 88, 27, 3003.00, ''),
('8813', 88, 18, 400.00, ''),
('8814', 88, 17, 500.00, ''),
('8815', 88, 22, 1000.00, 'TIMBRES PARA FACTURA CONTABILIDAD'),
('8816', 88, 22, 6190.00, 'ANEXO GASTOS PELADORA'),
('8817', 88, 22, 24652.00, 'ANEXO GASTOS TOSTON'),
('8818', 88, 29, 1240.00, ''),
('882', 88, 3, 11700.00, ''),
('883', 88, 2, 25025.00, ''),
('884', 88, 4, 7200.00, ''),
('885', 88, 14, 2774.00, ''),
('886', 88, 16, 200.00, ''),
('887', 88, 12, 8000.00, ''),
('888', 88, 22, 250.00, 'NANCY'),
('889', 88, 26, 100.00, ''),
('891', 89, 1, 178141.48, ''),
('8910', 89, 24, 10000.00, ''),
('8911', 89, 18, 200.00, ''),
('8912', 89, 17, 200.00, ''),
('8913', 89, 7, 20000.00, ''),
('8914', 89, 27, 2850.00, ''),
('8915', 89, 22, 28441.59, 'ANEXO GASTOS PELADORA'),
('8916', 89, 22, 1378.87, 'ANEXO GASTOS TOSTON'),
('892', 89, 3, 12800.00, ''),
('893', 89, 4, 2400.00, ''),
('894', 89, 2, 23750.00, ''),
('895', 89, 14, 2774.00, ''),
('896', 89, 16, 200.00, ''),
('897', 89, 12, 8000.00, ''),
('898', 89, 22, 250.00, 'NANCY'),
('899', 89, 26, 100.00, ''),
('901', 90, 1, 181189.59, ''),
('9010', 90, 18, 400.00, ''),
('9011', 90, 24, 10000.00, ''),
('9012', 90, 7, 20000.00, ''),
('9013', 90, 27, 2910.00, ''),
('9014', 90, 22, 13044.77, 'ANEXO GASTOS PELADORA'),
('9015', 90, 22, 1378.87, 'ANEXO GASTOS TOSTON'),
('902', 90, 3, 12600.00, ''),
('903', 90, 4, 2400.00, ''),
('904', 90, 2, 24250.00, ''),
('905', 90, 14, 2774.00, ''),
('906', 90, 16, 200.00, ''),
('907', 90, 12, 8000.00, ''),
('908', 90, 22, 250.00, 'NANCY'),
('909', 90, 26, 100.00, ''),
('911', 91, 1, 196708.41, ''),
('9110', 91, 26, 100.00, ''),
('9111', 91, 18, 400.00, ''),
('9112', 91, 13, 53149.00, ''),
('9113', 91, 22, 200.00, 'GASOLINA NOE'),
('9114', 91, 22, 8000.00, 'RENTA APARTAMENTO'),
('9115', 91, 22, 0.00, 'BOLSAS TEAPA'),
('9116', 91, 27, 2931.00, ''),
('9117', 91, 22, 1393.00, 'GAS NISSAN'),
('9118', 91, 22, 20331.56, 'ANEXO GASTOS PELADORA'),
('9119', 91, 5, 74655.40, ''),
('912', 91, 3, 13850.00, ''),
('913', 91, 4, 3000.00, ''),
('914', 91, 2, 24425.00, ''),
('915', 91, 14, 2774.00, ''),
('916', 91, 16, 200.00, ''),
('917', 91, 22, 100.00, 'GASOLINA ZOYLA'),
('918', 91, 12, 8000.00, ''),
('919', 91, 22, 250.00, 'NANCY'),
('921', 92, 1, 195721.30, ''),
('9210', 92, 22, 200.00, 'GASOLINA MCKLIN'),
('9211', 92, 13, 1038.00, ''),
('9212', 92, 22, 100.00, 'GASOLINA NOE'),
('9213', 92, 27, 2988.00, 'BOLSAS AGUINALDO E89'),
('9214', 92, 22, 1220.00, 'GAS NISSAN'),
('9215', 92, 18, 400.00, ''),
('9216', 92, 22, 4944.00, 'ANEXI GASTOS E89'),
('9217', 92, 2, 24900.00, ''),
('9218', 92, 4, 2400.00, ''),
('922', 92, 3, 13550.00, ''),
('923', 92, 14, 2774.00, ''),
('924', 92, 16, 200.00, ''),
('925', 92, 12, 8000.00, ''),
('926', 92, 22, 250.00, 'NANCY'),
('927', 92, 22, 100.00, 'GASOLINA ZOILA'),
('928', 92, 26, 100.00, ''),
('929', 92, 22, 200.00, 'GASOLINA ADRIAN'),
('931', 93, 1, 166724.81, ''),
('9310', 93, 22, 200.00, 'GASOLINA MCKLIN'),
('9311', 93, 13, 60000.00, ''),
('9312', 93, 22, 200.00, 'GASOLINA NOE'),
('9313', 93, 22, 20000.00, 'RENTA BODEGA TOSTON'),
('9314', 93, 27, 2532.00, ''),
('9315', 93, 17, 1100.00, ''),
('9316', 93, 18, 200.00, ''),
('9317', 93, 22, 2950.00, 'ANEXO GASTOS PELADORA'),
('9318', 93, 2, 21100.00, ''),
('9319', 93, 4, 2400.00, ''),
('932', 93, 3, 13300.00, ''),
('933', 93, 14, 2774.00, ''),
('934', 93, 16, 200.00, ''),
('935', 93, 15, 8500.00, ''),
('936', 93, 12, 8000.00, ''),
('937', 93, 22, 250.00, 'NANCY'),
('938', 93, 26, 100.00, ''),
('939', 93, 22, 200.00, 'GASOLINA ADRIAN'),
('941', 94, 1, 191019.52, ''),
('9410', 94, 13, 40496.00, ''),
('9411', 94, 22, 200.00, 'GASOLINA NOE'),
('9412', 94, 22, 1625.00, 'ENERGIA ELECTRICA TOSTON'),
('9413', 94, 27, 2904.00, ''),
('9414', 94, 17, 1135.00, ''),
('9415', 94, 18, 200.00, ''),
('9416', 94, 22, 850.00, 'GASTOS PELADORA (PERSONAL)'),
('9417', 94, 4, 2400.00, ''),
('9418', 94, 2, 24200.00, ''),
('942', 94, 3, 12500.00, ''),
('943', 94, 14, 2774.00, ''),
('944', 94, 16, 200.00, ''),
('945', 94, 22, 8000.00, 'RENTA APARTAMENTO JOSE'),
('946', 94, 12, 8000.00, ''),
('947', 94, 26, 100.00, ''),
('948', 94, 22, 200.00, 'GASOLINA ADRIAN'),
('949', 94, 22, 200.00, 'GASOLINA MCKLIN'),
('951', 95, 1, 190723.45, ''),
('9510', 95, 22, 200.00, 'GASOLINA MCKLIN'),
('9511', 95, 13, 30000.00, ''),
('9512', 95, 22, 200.00, 'GASOLINA NOE'),
('9513', 95, 27, 2979.00, ''),
('9514', 95, 17, 1230.00, ''),
('9515', 95, 22, 100.00, 'PELADORA (PERSONAL)'),
('9516', 95, 22, 1697.50, 'PELADORA(MATERIAL PARA MUFA Y REPARACION PISO)'),
('9517', 95, 22, 1300.00, 'PELADORA (PAO ARRAFON MUFA PREPARACION)'),
('9518', 95, 22, 380.00, 'PELADORA (2 CUBREBOCA ESPECIAL 15 DIAS C/U)'),
('9519', 95, 22, 300.00, 'PELADORA (REPARACION PISO)'),
('952', 95, 3, 12800.00, ''),
('9520', 95, 22, 330.00, 'PELADORA (PAQUETERIA PIEZA TOSTON)'),
('9521', 95, 22, 2400.00, 'PELADORA (TRABAJO TORNO )'),
('9522', 95, 22, 300.00, 'PELADORA (APOYO EMILI)'),
('9523', 95, 2, 24825.00, ''),
('9524', 95, 4, 2400.00, ''),
('953', 95, 14, 2774.00, ''),
('954', 95, 16, 200.00, ''),
('955', 95, 22, 8125.00, 'ENERGIA ELECTRICCA PELADORA'),
('956', 95, 12, 8000.00, ''),
('957', 95, 22, 250.00, 'NANCY'),
('958', 95, 26, 100.00, ''),
('959', 95, 22, 200.00, 'GASOLINA ADRIAN'),
('961', 96, 1, 182759.25, ''),
('9610', 96, 26, 100.00, ''),
('9611', 96, 22, 200.00, 'GASOLINA ADRIAN'),
('9612', 96, 22, 200.00, 'GASOLINA MCKLIN'),
('9613', 96, 13, 40000.00, ''),
('9614', 96, 22, 200.00, 'GASOLINA NOE'),
('9615', 96, 15, 8500.00, ''),
('9616', 96, 27, 2862.00, ''),
('9617', 96, 17, 1150.00, ''),
('9618', 96, 4, 2400.00, ''),
('9619', 96, 2, 23850.00, ''),
('962', 96, 3, 12200.00, ''),
('963', 96, 22, 250.00, 'PELADORA (PERSONAL)'),
('964', 96, 22, 450.00, 'PELADORA(REPARACION DE CARRETILLA Y CARRITO DE TRA'),
('965', 96, 22, 2300.00, 'PELADORA (CUBRE BOCAS LEYDI)'),
('966', 96, 14, 2774.00, ''),
('967', 96, 16, 200.00, ''),
('968', 96, 12, 8000.00, ''),
('969', 96, 22, 250.00, 'NANCY'),
('971', 97, 1, 187480.83, ''),
('9710', 97, 26, 100.00, ''),
('9711', 97, 22, 200.00, 'GASOLINA ADRIAN'),
('9712', 97, 22, 200.00, 'GASOLINA MCKLIN'),
('9713', 97, 13, 70000.00, ''),
('9714', 97, 22, 200.00, 'GASOLINA NOE'),
('9715', 97, 22, 20000.00, 'RENTA TOSTON JUNIO'),
('9716', 97, 22, 46.00, 'LUZ ELECTRICA JOSE ADOLFO'),
('9717', 97, 22, 8000.00, 'APP JOSE'),
('9718', 97, 27, 2874.00, ''),
('9719', 97, 17, 1290.00, ''),
('972', 97, 3, 12200.00, ''),
('9720', 97, 4, 2400.00, ''),
('9721', 97, 2, 23950.00, ''),
('973', 97, 22, 230.00, 'PELADORA( PERSONAL, POZOL, VASOS)'),
('974', 97, 22, 1000.00, 'APOYO ADAN Y MANUEL'),
('975', 97, 22, 57200.00, 'PELADORA (MANKOZEB Y RECINA)'),
('976', 97, 14, 2774.00, ''),
('977', 97, 16, 200.00, ''),
('978', 97, 12, 8000.00, ''),
('979', 97, 22, 250.00, 'NANCY'),
('981', 98, 1, 147567.98, ''),
('9810', 98, 22, 200.00, 'GASOLINA ADRIAN'),
('9811', 98, 22, 200.00, 'GASOLINA MCKLIN'),
('9812', 98, 22, 200.00, 'GASOLINA NOE'),
('9813', 98, 27, 2295.00, ''),
('9814', 98, 17, 1450.00, ''),
('9815', 98, 2, 19125.00, ''),
('9816', 98, 4, 2400.00, ''),
('982', 98, 3, 12300.00, ''),
('983', 98, 22, 280.00, 'POSOL HIELO BASOS'),
('984', 98, 22, 1000.00, 'APOYO MANUEL Y ADAN '),
('985', 98, 14, 2774.00, ''),
('986', 98, 16, 200.00, ''),
('987', 98, 12, 8000.00, ''),
('988', 98, 22, 250.00, 'NANCY'),
('989', 98, 26, 100.00, ''),
('991', 99, 1, 192222.70, ''),
('9910', 99, 22, 6829.00, 'ENERIA ELECTRICA PELADORA'),
('9911', 99, 12, 8000.00, ''),
('9912', 99, 22, 250.00, 'NANCY'),
('9913', 99, 26, 100.00, ''),
('9914', 99, 22, 200.00, 'GASOLINA ADRIAN'),
('9915', 99, 22, 200.00, 'GASOLINA MCKLIN'),
('9916', 99, 22, 200.00, 'GASOLINA NOE'),
('9917', 99, 27, 2823.00, ''),
('9918', 99, 17, 1800.00, ''),
('9919', 99, 2, 23525.00, ''),
('992', 99, 3, 11900.00, ''),
('9920', 99, 4, 2400.00, ''),
('993', 99, 22, 230.00, 'POZOL HIELO BASOS'),
('994', 99, 22, 1000.00, 'APOYO MANUEL Y ADAN '),
('995', 99, 22, 1200.00, 'COMPRA DE ETIQUETAS PARA BOLSAS'),
('996', 99, 22, 1300.00, 'SERVICIO, LAVADO Y EGRSADO DE CAMIONETA'),
('997', 99, 22, 2000.00, 'NOE'),
('998', 99, 14, 2774.00, ''),
('999', 99, 16, 200.00, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `peladores`
--

DROP TABLE IF EXISTS `peladores`;
CREATE TABLE `peladores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(111) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) NOT NULL,
  `edad` int(2) DEFAULT 0,
  `telefono` varchar(12) DEFAULT NULL,
  `direccion` varchar(100) NOT NULL,
  `no_cuenta` varchar(20) DEFAULT NULL,
  `Tipo` int(2) NOT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `estado` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `peladores`
--

INSERT INTO `peladores` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `foto`, `estado`) VALUES
(1, 'YOMAILI', 'HERNANDEZ', 'DE DIOS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(2, 'JOSE MANUEL', 'MALDONADO', 'A', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(3, 'ELMER EBERTO', 'GARCIA', 'MONZON', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(4, 'SHEILA KARELI', 'ARIAS', 'LARA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(5, 'MARCO ANTONIO', 'LAZARO', 'HERNANDEZ', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(6, 'DIANA', '', '', 0, '', '-', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(7, 'CLARIBEL', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(8, 'KEVIN GERAR', 'ARIAS', 'ZENTELLA', 0, '', 'CUNDUACAN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(9, 'WALTER', 'MIRANDA', 'SUAREZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(10, 'HIGINIA', 'RODRIGUEZ', 'VASCONCELOS', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(11, 'PERLA RUBI', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(12, 'MARIA', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(13, 'RICARDO', 'OVANDO', 'FRANCISCO', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(14, 'MARIA GUADALUPE', 'ARIAS', 'LARA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(15, 'CECILIA', 'FRANCISCO', 'DE JESUS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(16, 'DANIEL', 'ENRRIQUE', 'DE LOS SANTOS', 0, '', 'MORELITOS', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(17, 'EMILI', 'SENTELLA', 'LOPEZ', 0, '', 'MORELITOS', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(18, 'JOSE ALBERT', 'RAMON', 'LAZARO', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(19, 'MARIA ESTELA', 'FRANCISCO', 'DE JESUS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(20, 'EDITH', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(21, 'ZOILA', 'VALENCIA', 'BAUTISTA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(22, 'DANIELA CRI', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(23, 'MARINA', 'LAZARO', 'RAMOS', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(24, 'ROSA ISELA', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(25, 'ANGEL MATEO', 'GOMEZ', 'GUTIERREZ', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(26, 'LINDA ANAI', 'GARCIA', 'GUTIERREZ', 0, '', 'JALPA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(27, 'TANIA SUGEY', 'VASCONCELOS', 'LAZARO', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(28, 'YADIRA', 'ROMERO', 'GARCIA', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(29, 'SURI DANIEL', 'LAZARO', 'ROMERO', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(30, 'ADRIAN DRAW', 'LAZARO', 'CONTRERAS', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(31, 'LUIS ANGEL', 'MARTIN', 'MAY', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(32, 'SABDIEL', 'MARTIN', 'VOLAINA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(33, 'ADAN', 'ALBERTO', 'HERNANDEZ', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(34, 'TEREZA', 'AGUILAR', 'ZAPATA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(35, 'BRAYAN', 'AGUILAR', 'ZAPATA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(37, 'ABIMAEL', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(38, 'AUDELIN', '', '', 0, '', '-', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(39, 'ADOLFO', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(40, 'ALBERTO', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(41, 'ALEXIS', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(42, 'ANA YENY', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(43, 'ANDRES', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(44, 'ASUNCION', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(45, 'AUDELIN', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(46, 'AURA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(47, 'BETO', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(48, 'CHUCHITA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(49, 'CHUCHITO', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(50, 'CRISTEL', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(51, 'ESTELA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(52, 'FELIX', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(53, 'GERARDO', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(54, 'GLORIA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(55, 'HIJINIA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(56, 'INGRID', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(57, 'ISAI', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(58, 'ISIDORA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(59, 'JAIME', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(60, 'KARELY', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(61, 'KARINA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(62, 'LIZBETH', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(63, 'LUIS', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(64, 'MARIA GUADALUPE', 'ARIAS', 'LARA', 0, '', '#', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(65, 'MACLIN', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(66, 'MADIN', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(67, 'MANUEL', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(68, 'MARCOS', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(69, 'MARIANA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(70, 'MISAEL', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(71, 'PETRONA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(72, 'RICARDA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(73, 'SARA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(74, 'SEBASTIAN', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(75, 'SELENE', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(76, 'SURY', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(77, 'TERESA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(78, 'VENNY', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(79, 'VIRGINIA', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(80, 'YAIR', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 2),
(81, 'YONATAN', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(82, 'YONY', '', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 1),
(83, 'MARCOS', 'LECHUGAL', '', 0, '', '-', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(84, 'HERNAN', '', '', 0, '', '#', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(85, 'LETICIA', '', '', 0, '', '#', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0),
(86, 'RAMIRO', '', '', 0, '', '#', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pelador_extra`
--

DROP TABLE IF EXISTS `pelador_extra`;
CREATE TABLE `pelador_extra` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_bolsaspelador` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `trabajo` int(11) NOT NULL,
  `concepto` varchar(30) DEFAULT NULL,
  `pago` float NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pesos`
--

DROP TABLE IF EXISTS `pesos`;
CREATE TABLE `pesos` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_cuenta` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `concepto` varchar(255) NOT NULL,
  `ingreso` double(10,2) DEFAULT 0.00,
  `egreso` double(10,2) DEFAULT 0.00,
  `saldo` double(10,2) NOT NULL,
  `gastos_embarque` double(10,2) DEFAULT 0.00,
  `idDolar` varchar(11) DEFAULT '0',
  `activo` int(2) DEFAULT 0,
  `mostrar` int(2) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `pesos`
--

INSERT INTO `pesos` (`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `gastos_embarque`, `idDolar`, `activo`, `mostrar`) VALUES
('1001', '1001', 'SALDO ANTERIOR', 0.00, 0.00, 159731.41, 0.00, '0', 0, 1),
('1002', '1001', 'GASTOS E100', 0.00, 424989.00, -265257.59, 28263.20, '0', 0, 1),
('1003', '1001', 'CAMBIO E100', 226958.01, 0.00, -38299.59, 0.00, '1002', 0, 1),
('1004', '1001', 'CAMBIO E100', 230512.01, 0.00, 192212.41, 0.00, '1003', 0, 1),
('1005', '1001', 'COMISION JUNIO BANCO', 0.00, 1044.00, 191168.41, 0.00, '0', 1, 1),
('1011', '1011', 'SALDO ANTERIOR', 0.00, 0.00, 191168.41, 0.00, '0', 0, 1),
('1012', '1011', 'GASTOS E101', 0.00, 356434.40, -165265.99, 34387.20, '0', 0, 1),
('1013', '1011', 'CAMBIO E101', 228026.01, 0.00, 62760.02, 0.00, '1013', 0, 1),
('1021', '1021', 'SALDO ANTERIOR', 0.00, 0.00, 62760.02, 0.00, '0', 0, 1),
('1022', '1021', 'GASTOS E102', 0.00, 265708.40, -202948.38, 28288.00, '0', 0, 1),
('1023', '1021', 'CAMBIO E102', 244889.69, 0.00, 41941.31, 0.00, '1023', 0, 1),
('1031', '1031', 'SALDO ANTERIOR', 0.00, 0.00, 41941.31, 0.00, '0', 0, 1),
('1032', '1031', 'GASTOS E103', 0.00, 255053.70, -213112.39, 34512.00, '0', 0, 1),
('1033', '1031', 'CAMBIO 103', 267740.41, 0.00, 54628.02, 0.00, '1033', 0, 1),
('1041', '1041', 'SALDO ANTERIOR', 0.00, 0.00, 54628.02, 0.00, '0', 0, 1),
('1042', '1041', 'GASTOS E104', 0.00, 306253.76, -251625.74, 27802.40, '0', 0, 1),
('1043', '1041', 'CAMBIO E104', 263589.59, 0.00, 11963.85, 0.00, '1043', 0, 1),
('1044', '1041', 'COMISIO TOKEN', 0.00, 290.00, 11673.85, 0.00, '0', 1, 1),
('1051', '1051', 'SALDO ANTERIOR', 0.00, 0.00, 11673.85, 0.00, '0', 0, 1),
('1052', '1051', 'GASTOS E105', 0.00, 309614.36, -297940.51, 28616.80, '0', 0, 1),
('1053', '1051', 'CAMBIO E105', 293103.20, 0.00, -4837.31, 0.00, '1053', 0, 1),
('1054', '1051', 'CAMBIO E105', 22714.20, 0.00, 17876.89, 0.00, '1054', 0, 1),
('1055', '1051', 'COMISION', 0.00, 1044.00, 16832.89, 0.00, '0', 1, 1),
('1061', '1061', 'SALDO ANTERIOR', 0.00, 0.00, 16832.89, 0.00, '0', 0, 1),
('1062', '1061', 'GASTOS E106', 0.00, 305669.02, -288836.13, 27608.00, '0', 0, 1),
('1063', '1061', 'CAMBIO E106', 289684.19, 0.00, 848.06, 0.00, '1063', 0, 1),
('1071', '1071', 'SALDO ANTERIOR', 0.00, 0.00, 848.06, 0.00, '0', 0, 1),
('1072', '1071', 'GASTOS E107', 0.00, 276519.10, -275671.04, 28173.20, '0', 0, 1),
('1073', '1071', 'CAMBIO 107', 132851.39, 0.00, -142819.65, 0.00, '1073', 0, 1),
('1074', '1071', 'CAMBIO E107', 132153.00, 0.00, -10666.65, 0.00, '1074', 0, 1),
('1081', '1081', 'SALDO ANTERIOR', 0.00, 0.00, -10666.65, 0.00, '0', 0, 1),
('1082', '1081', 'GASTOS E108', 0.00, 266389.92, -277056.57, 34649.60, '0', 0, 1),
('1083', '1081', 'CAMBIO', 132122.39, 0.00, -144934.18, 0.00, '1083', 0, 1),
('1084', '1081', 'CAMBIO E108', 153704.60, 0.00, 8770.42, 0.00, '1084', 0, 1),
('1091', '1091', 'SALDO ANTERIOR', 0.00, 0.00, 8770.42, 0.00, '0', 0, 1),
('1092', '1091', 'GASTOS E109', 0.00, 334830.80, -326060.38, 0.00, '0', 0, 1),
('1093', '1091', 'CAMBIO E109', 295417.79, 0.00, -30642.59, 0.00, '1093', 0, 1),
('1094', '1091', 'CAMBIO E109', 32255.85, 0.00, 1613.26, 0.00, '1094', 0, 1),
('1095', '1091', 'COMISION', 0.00, 1044.00, 569.26, 0.00, '0', 1, 1),
('1101', '1101', 'SALDO ANTERIOR', 0.00, 0.00, 569.26, 0.00, '0', 0, 1),
('1102', '1101', 'GASTOS E110', 0.00, 262813.65, -262244.39, 24079.20, '0', 0, 1),
('1103', '1101', 'CAMBIO E110', 215561.01, 0.00, -46683.38, 0.00, '1103', 0, 1),
('1104', '1101', 'CAMBIO E110', 107401.50, 0.00, 60718.12, 0.00, '1104', 0, 1),
('1105', '1101', 'CAMBIO E110', 296594.21, 0.00, 357312.33, 0.00, '1105', 0, 1),
('1111', '1111', 'SALDO ANTERIOR', 0.00, 0.00, 357312.33, 0.00, '0', 0, 1),
('1112', '1111', 'GASTOS E111', 0.00, 277279.40, 80032.93, 39866.40, '0', 0, 1),
('1121', '1121', 'SALDO ANTERIOR', 0.00, 0.00, 80032.93, 0.00, '0', 0, 1),
('1122', '1121', 'GASTOS E112', 0.00, 298644.80, -218611.87, 43683.20, '0', 0, 1),
('1123', '1121', 'CAMBIO E112', 225895.00, 0.00, 7283.13, 0.00, '1123', 0, 1),
('1124', '1121', 'CAMBIO E112', 88386.80, 0.00, 95669.93, 0.00, '1124', 0, 1),
('1125', '1121', 'CAMBIO E114', 299643.39, 0.00, 395313.32, 0.00, '1125', 0, 1),
('1131', '1131', 'SALDO ANTERIOR', 0.00, 0.00, 395313.32, 0.00, '0', 0, 1),
('1132', '1131', 'GASTOS E113', 0.00, 337269.00, 58044.32, 40636.00, '0', 0, 1),
('1133', '1131', 'CAMBIO E113', 331432.51, 0.00, 389476.83, 0.00, '1133', 0, 1),
('1141', '1141', 'SALDO ANTERIOR', 0.00, 0.00, 389476.83, 0.00, '0', 0, 1),
('1142', '1141', 'GASTOS E114', 0.00, 268760.53, 120716.30, 56542.40, '0', 0, 1),
('1143', '1141', 'CAMBIO E114', 300399.40, 0.00, 421115.70, 0.00, '1143', 0, 1),
('1144', '1141', 'COMISION BANCO', 0.00, 1044.00, 420071.70, 0.00, '0', 1, 1),
('1151', '1151', 'SALDO ANTERIOR', 0.00, 0.00, 420071.70, 0.00, '0', 0, 1),
('1152', '1151', 'GASTOS E115', 0.00, 269052.80, 151018.90, 492.00, '0', 0, 1),
('1153', '1151', 'CAMBIO 1', 255706.81, 0.00, 406725.71, 0.00, '1153', 0, 1),
('1154', '1151', 'CAMBIO 2', 63759.96, 0.00, 470485.67, 0.00, '1154', 0, 1),
('1161', '1161', 'SALDO ANTERIOR', 0.00, 0.00, 470485.67, 0.00, '0', 0, 1),
('1162', '1161', 'GASTOS E116', 0.00, 398133.49, 72352.18, 1500.00, '0', 0, 1),
('1163', '1161', 'CAMBIO 1', 378143.99, 0.00, 450496.17, 0.00, '1163', 0, 1),
('1171', '1171', 'SALDO ANTERIOR', 0.00, 0.00, 450496.17, 0.00, '0', 0, 1),
('1172', '1171', 'GASTOS E117', 0.00, 349806.28, 100689.89, 55932.80, '0', 0, 1),
('1173', '1171', 'CAMBIO E117', 337160.00, 0.00, 437849.89, 0.00, '1173', 0, 1),
('1174', '1171', 'COMISION BANCO', 0.00, 1044.00, 436805.89, 0.00, '0', 1, 1),
('1181', '1181', 'SALDO ANTERIOR', 0.00, 0.00, 436805.89, 0.00, '0', 0, 1),
('1182', '1181', 'GASTOS E118', 0.00, 457358.80, -20552.91, 7360.00, '0', 0, 1),
('1183', '1181', 'CAMBIO 1', 376599.59, 0.00, 356046.68, 0.00, '1183', 0, 1),
('1191', '1191', 'SALDO ANTERIOR', 0.00, 0.00, 356046.68, 0.00, '0', 0, 1),
('1192', '1191', 'GASTOS E119', 0.00, 303445.44, 52601.24, 55406.80, '0', 0, 1),
('1193', '1191', 'CAMBIO 1', 323041.60, 0.00, 375642.84, 0.00, '1193', 0, 1),
('1201', '1201', 'SALDO ANTERIOR', 0.00, 0.00, 375642.84, 0.00, '0', 0, 1),
('1202', '1201', 'GASTOS E120', 0.00, 261786.45, 113856.39, 20070.40, '0', 0, 1),
('1203', '1201', 'CAMBIO E120', 280138.59, 0.00, 393994.98, 0.00, '1203', 0, 1),
('1211', '1211', 'SALDO ANTERIOR', 0.00, 0.00, 393994.98, 0.00, '0', 0, 1),
('1212', '1211', 'GASTOS E121', 0.00, 287164.10, 106830.88, 41972.80, '0', 0, 1),
('1213', '1211', 'CAMBIO E121', 201170.01, 0.00, 308000.89, 0.00, '1213', 0, 1),
('1214', '1211', 'CAMBIO 2 E121', 79986.00, 0.00, 387986.89, 0.00, '1214', 0, 1),
('1215', '1211', 'COMISION BANCO', 0.00, 1044.00, 386942.89, 0.00, '0', 1, 1),
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 11240.38, 0.00, '0', 0, 1),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 11240.38, 0.00, '0', 0, 1),
('772', '771', 'GASTOS E77', 0.00, 278975.70, -267735.32, 0.00, '0', 0, 1),
('773', '771', 'CAMBIO E77', 270607.69, 0.00, 2872.37, 0.00, '773', 0, 1),
('781', '781', 'SALDO ANTERIOR', 0.00, 0.00, 2872.37, 0.00, '0', 0, 1),
('782', '781', 'GASTOS E78', 0.00, 255276.70, -252404.33, 0.00, '0', 0, 1),
('783', '781', 'CAMBIO E78', 254447.99, 0.00, 2043.66, 0.00, '782', 0, 1),
('784', '781', 'INGRESO', 1044.00, 0.00, 3087.66, 0.00, '0', 1, 1),
('791', '791', 'SALDO ANTERIOR', 0.00, 0.00, 3087.66, 0.00, '0', 0, 1),
('792', '791', 'GASTOS E79', 0.00, 355764.66, -352676.98, 0.00, '0', 0, 1),
('793', '791', 'CAMBIO E79', 18633.90, 0.00, -334043.08, 0.00, '793', 0, 1),
('794', '791', 'CAMBIO E79', 334119.61, 0.00, 76.53, 0.00, '795', 0, 1),
('801', '801', 'SALDO ANTERIOR', 0.00, 0.00, 516.52, 0.00, '0', 0, 1),
('802', '801', 'GASTOS E80', 0.00, 227790.81, -227274.28, 0.00, '0', 0, 1),
('803', '801', 'CAMBIO E80', 18719.40, 0.00, -208554.88, 0.00, '803', 0, 1),
('804', '801', 'CAMBIO E80', 424973.46, 0.00, 216418.58, 0.00, '804', 0, 1),
('811', '811', 'SALDO ANTERIOR', 0.00, 0.00, 216418.00, 0.00, '0', 0, 1),
('812', '811', 'GASTOS E81', 0.00, 202766.10, 13651.90, 0.00, '0', 0, 1),
('821', '821', 'SALDO ANTERIOR', 0.00, 0.00, 13651.90, 0.00, '0', 0, 1),
('822', '821', 'GASTOS E82', 0.00, 288411.10, -274759.20, 0.00, '0', 0, 1),
('823', '821', 'CAMBIO E82', 253309.96, 0.00, -21449.24, 0.00, '823', 0, 1),
('824', '821', 'CAMBIO E82', 28407.45, 0.00, 6958.21, 0.00, '824', 0, 1),
('831', '831', 'SALDO ANTERIOR', 0.00, 0.00, 6958.21, 0.00, '0', 0, 1),
('832', '831', 'GASTOS E83', 0.00, 302578.29, -295620.09, 0.00, '0', 0, 1),
('833', '831', 'CAMBIO E83', 56919.60, 0.00, -238700.49, 0.00, '833', 0, 1),
('834', '831', 'CAMBIO E83', 216466.81, 0.00, -22233.68, 0.00, '834', 0, 1),
('835', '831', 'COMICION BANCO', 0.00, 1044.00, -23277.68, 0.00, '0', 1, 1),
('841', '841', 'SALDO ANTERIOR', 0.00, 0.00, 5720.90, 0.00, '0', 0, 1),
('842', '841', 'GASTOS E84', 0.00, 255261.40, -249540.50, 0.00, '0', 0, 1),
('843', '841', 'CAMBIO E84', 233872.81, 0.00, -15667.70, 0.00, '843', 0, 1),
('851', '851', 'SALDO ANTERIOR', 0.00, 0.00, -15667.70, 0.00, '0', 0, 1),
('852', '851', 'GASTOS E85', 0.00, 273311.00, -288978.70, 28213.80, '0', 0, 1),
('853', '851', 'CAMBIO E85', 296997.40, 0.00, 8018.70, 0.00, '853', 0, 1),
('861', '861', 'SALDO ANTERIOR', 0.00, 0.00, 8018.70, 0.00, '0', 0, 1),
('862', '861', 'GASTOS E86', 0.00, 297421.20, -289402.50, 30627.60, '0', 0, 1),
('863', '861', 'CAMBIO E886', 332738.00, 0.00, 43335.50, 0.00, '863', 0, 1),
('871', '871', 'SALDO ANTERIOR', 0.00, 0.00, 8018.70, 0.00, '0', 0, 1),
('872', '871', 'GASTOS E87', 0.00, 267772.09, -259753.39, 0.00, '0', 0, 1),
('873', '871', 'CAMBIO E886', 332738.00, 0.00, 72984.61, 0.00, '874', 0, 1),
('881', '881', 'SALDO ANTERIOR', 0.00, 0.00, 217226.19, 0.00, '0', 0, 1),
('882', '881', 'GASTOS E88', 0.00, 337995.59, -120769.41, 75848.00, '0', 0, 1),
('883', '881', 'CAMBIO UNO', 294176.40, 0.00, 173406.99, 0.00, '883', 0, 1),
('884', '881', 'COMISION BANCO', 0.00, 1044.00, 172362.99, 0.00, '0', 1, 1),
('891', '891', 'SALDO ANTERIOR', 0.00, 0.00, 172362.99, 0.00, '0', 0, 1),
('892', '891', 'GASTOS E89', 0.00, 291485.94, -119122.95, 30326.30, '0', 0, 1),
('893', '891', 'CAMBIO UNO', 262281.80, 0.00, 143158.85, 0.00, '893', 0, 1),
('901', '901', 'SALDO ANTERIOR', 0.00, 0.00, 172362.99, 0.00, '0', 0, 1),
('902', '901', 'GASTOS E90', 0.00, 279497.23, -107134.24, 64423.40, '0', 0, 1),
('903', '901', 'CAMBIO UNO', 262281.80, 0.00, 155147.56, 0.00, '903', 0, 1),
('911', '911', 'SALDO ANTERIOR', 0.00, 0.00, 147440.59, 0.00, '0', 0, 1),
('912', '911', 'GASTOS E91', 0.00, 410467.37, -263026.77, 0.00, '0', 0, 1),
('913', '911', 'CAMBIO UNO', 367644.00, 0.00, 104617.23, 0.00, '913', 0, 1),
('921', '921', 'SALDO ANTERIOR', 0.00, 0.00, 104617.23, 0.00, '0', 0, 1),
('922', '921', 'GASTOS E92', 0.00, 259085.31, -154468.08, 52692.00, '0', 0, 1),
('923', '921', 'CAMBIO ', 321561.50, 0.00, 167093.42, 0.00, '922', 0, 1),
('931', '931', 'SALDO ANTERIOR', 0.00, 0.00, 167093.42, 0.00, '0', 0, 1),
('932', '931', 'GASTOS E93', 0.00, 310730.80, -143637.38, 43498.80, '0', 0, 1),
('933', '931', 'CAMBIO', 285265.21, 0.00, 141627.83, 0.00, '933', 0, 1),
('941', '941', 'SALDO ANTERIOR', 0.00, 0.00, 141627.83, 0.00, '0', 0, 1),
('942', '941', 'GASTOS E94', 0.00, 297003.50, -155375.67, 39620.80, '0', 0, 1),
('943', '941', 'CAMBIO', 288022.80, 0.00, 132647.13, 0.00, '943', 0, 1),
('944', '941', 'COMISION ABRIL', 0.00, 1044.00, 131603.13, 0.00, '0', 1, 1),
('951', '951', 'SALDO ANTERIOR', 0.00, 0.00, 131603.13, 0.00, '0', 0, 1),
('952', '951', 'GASTOS E95', 0.00, 291813.96, -160210.83, 22412.76, '0', 0, 1),
('953', '951', 'CAMBIO', 302841.50, 0.00, 142630.67, 0.00, '953', 0, 1),
('961', '961', 'SALDO ANTERIOR', 0.00, 0.00, 142630.67, 0.00, '0', 0, 1),
('962', '961', 'GASTOS E96', 0.00, 288645.25, -146014.58, 40066.40, '0', 0, 1),
('963', '961', 'CAMBIO E96', 289819.40, 0.00, 143804.82, 0.00, '963', 0, 1),
('971', '971', 'SALDO ANTERIOR', 0.00, 0.00, 143804.82, 0.00, '0', 0, 1),
('972', '971', 'GASTOS E97', 0.00, 398594.80, -254789.98, 38320.00, '0', 0, 1),
('973', '971', 'CAMBIO E97', 303109.79, 0.00, 48319.82, 0.00, '973', 0, 1),
('974', '971', 'COMISION', 0.00, 1044.00, 47275.82, 0.00, '0', 1, 1),
('981', '981', 'SALDO ANTERIOR', 0.00, 0.00, 47275.82, 0.00, '0', 0, 1),
('982', '981', 'GASTOS E98', 0.00, 198342.00, -151066.18, 28272.80, '0', 0, 1),
('983', '981', 'CAMBIO E98', 299669.68, 0.00, 148603.51, 0.00, '983', 0, 1),
('991', '991', 'SALDO ANTERIOR', 0.00, 0.00, 148603.50, 0.00, '0', 0, 1),
('992', '991', 'GASTOS E99', 0.00, 259153.70, -110550.19, 23141.60, '0', 0, 1),
('993', '991', 'CAMBIO E99', 292281.60, 0.00, 181731.41, 0.00, '993', 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `planilla_toston`
--

DROP TABLE IF EXISTS `planilla_toston`;
CREATE TABLE `planilla_toston` (
  `id` int(11) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `ap_p` varchar(30) NOT NULL,
  `ap_m` varchar(30) NOT NULL,
  `edad` int(2) NOT NULL,
  `telefono` varchar(12) DEFAULT NULL,
  `direccion` varchar(100) NOT NULL,
  `no_cuenta` varchar(20) DEFAULT NULL,
  `tipo` int(2) NOT NULL,
  `estado` int(2) DEFAULT 1,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `planilla_toston`
--

INSERT INTO `planilla_toston` (`id`, `nombre`, `ap_p`, `ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `tipo`, `estado`, `foto`) VALUES
(1, 'MIGUEL', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'WILLIAN JOSE', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'YOSMAR', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'EDGAR', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'ANDRES', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'ARMANDO', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'DEYBI', '', '', 0, '', '--', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'ELEAZAR', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(11, 'DANIEL', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(12, 'DULCE', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(13, 'SAMUEL', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(14, 'KARLA', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(15, 'PEDRO', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(16, 'AUDELIN', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(17, 'SABDIEL', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(18, 'ENRRIQUE', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(19, 'GERSON', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(20, 'DANIELA', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(21, 'LUCIA', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(22, 'SHARI MICHELE', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(23, 'HERNAN', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(24, 'CARLOS', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(25, 'RICARDO', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(26, 'CLAUDIA', '', '', 0, '', '-', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(27, 'MATEO', '', '', 0, '', '#', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(28, 'ADAN', '', '', 0, '', '#', '', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(29, 'MARIA', '', '', 0, '', '#', '-', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(30, 'NOE', '', '', 0, '', '#', '-', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(31, 'MANUEL', '', '', 0, '', '#', '-', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(32, 'BETO', '', '', 0, '', '#', '-', 3, 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio_compra`
--

DROP TABLE IF EXISTS `precio_compra`;
CREATE TABLE `precio_compra` (
  `id_precio` int(11) NOT NULL,
  `cantidad` float NOT NULL,
  `pago_bolsero` float NOT NULL,
  `pago_pelador` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `precio_compra`
--

INSERT INTO `precio_compra` (`id_precio`, `cantidad`, `pago_bolsero`, `pago_pelador`) VALUES
(1, 4, 300, 25);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamos`
--

DROP TABLE IF EXISTS `prestamos`;
CREATE TABLE `prestamos` (
  `id` int(11) NOT NULL,
  `id_fruta` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `fungicida` float DEFAULT 0,
  `fertilizante` float DEFAULT 0,
  `prestamo` float DEFAULT 0,
  `no_pagos_fungicida` int(2) DEFAULT 0,
  `no_pagos_fertilizante` int(2) DEFAULT 0,
  `no_pagos_prestamo` int(2) DEFAULT 0,
  `abono_fungicida` float DEFAULT 0,
  `abono_fertilizante` float DEFAULT 0,
  `abono_prestamo` float DEFAULT 0,
  `saldo_fungicida` float DEFAULT 0,
  `saldo_fertilizante` float DEFAULT 0,
  `saldo_prestamo` float DEFAULT 0,
  `abono_cantidad_fungicida` float DEFAULT 0,
  `abono_cantidad_fertilizante` float DEFAULT 0,
  `abono_cantidad_prestamo` float DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `prestamos`
--

INSERT INTO `prestamos` (`id`, `id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES
(771, '771', 12100, 0, 0, 4, 0, 0, 3025, 0, 0, 9075, 0, 0, 3025, 0, 0),
(772, '772', 1700, 0, 0, 4, 0, 0, 425, 0, 0, 1275, 0, 0, 425, 0, 0),
(773, '773', 3400, 0, 0, 4, 0, 0, 850, 0, 0, 2550, 0, 0, 850, 0, 0),
(774, '774', 7000, 0, 0, 4, 0, 0, 1750, 0, 0, 5250, 0, 0, 1750, 0, 0),
(775, '775', 3600, 0, 0, 4, 0, 0, 900, 0, 0, 2700, 0, 0, 900, 0, 0),
(779, '779', 1700, 0, 0, 4, 0, 0, 425, 0, 0, 1275, 0, 0, 425, 0, 0),
(782, '782', 1275, 0, 0, 4, 0, 0, 425, 0, 0, 850, 0, 0, 425, 0, 0),
(783, '783', 2550, 0, 0, 4, 0, 0, 850, 0, 0, 1700, 0, 0, 850, 0, 0),
(784, '784', 5250, 0, 0, 4, 0, 0, 1750, 0, 0, 3500, 0, 0, 1750, 0, 0),
(789, '789', 1275, 0, 0, 4, 0, 0, 425, 0, 0, 850, 0, 0, 425, 0, 0),
(791, '791', 9075, 50800, 0, 4, 4, 0, 3025, 8466.67, 0, 6050, 42333.3, 0, 2268.75, 12700, 0),
(792, '793', 850, 5020, 0, 4, 4, 0, 425, 836.67, 0, 425, 4183.33, 0, 212.5, 1255, 0),
(793, '794', 1700, 15400, 0, 4, 4, 0, 850, 2566.67, 0, 850, 12833.3, 0, 425, 3850, 0),
(794, '795', 3500, 0, 0, 4, 0, 0, 1750, 0, 0, 1750, 0, 0, 875, 0, 0),
(795, '796', 2700, 13700, 0, 4, 4, 0, 900, 2283.33, 0, 1800, 11416.7, 0, 675, 3425, 0),
(801, '801', 6050, 42333.3, 0, 4, 4, 0, 3025, 8466.67, 0, 3025, 33866.7, 0, 2268.75, 12700, 0),
(802, '802', 425, 4183.33, 0, 4, 4, 0, 425, 836.67, 0, 0, 3346.66, 0, 212.5, 1255, 0),
(803, '803', 850, 12833.3, 0, 4, 4, 0, 850, 2566.67, 0, 0, 10266.7, 0, 425, 3850, 0),
(804, '804', 1750, 0, 0, 4, 0, 0, 1750, 0, 0, 0, 0, 0, 875, 0, 0),
(805, '805', 1800, 11416.7, 0, 4, 4, 0, 900, 2283.33, 0, 900, 9133.34, 0, 675, 3425, 0),
(812, '814', 0, 3346.66, 0, 4, 4, 0, 0, 836.6, 0, 0, 2510.06, 0, 212.5, 1255, 0),
(821, '822', 3025, 33866.7, 0, 4, 4, 0, 3025, 8466.7, 0, 0, 25400, 0, 2268.75, 12700, 0),
(822, '824', 0, 2510.06, 0, 4, 4, 0, 0, 837.06, 0, 0, 1673, 0, 212.5, 1255, 0),
(823, '825', 0, 10266.7, 0, 4, 4, 0, 0, 2566.7, 0, 0, 7700, 0, 425, 3850, 0),
(825, '827', 900, 9133.34, 0, 4, 4, 0, 900, 2283.67, 0, 0, 6849.67, 0, 675, 3425, 0),
(829, '829', 850, 0, 0, 4, 0, 0, 425, 0, 0, 425, 0, 0, 425, 0, 0),
(831, '8317', 0, 25400, 0, 4, 4, 0, 0, 8466.67, 0, 0, 16933.3, 0, 2268.75, 12700, 0),
(832, '8315', 0, 1673, 0, 4, 4, 0, 0, 836.667, 0, 0, 836.333, 0, 212.5, 1255, 0),
(833, '8314', 0, 7700, 0, 4, 4, 0, 0, 2566.67, 0, 0, 5133.33, 0, 425, 3850, 0),
(835, '8312', 0, 6849.67, 0, 4, 4, 0, 0, 2283, 0, 0, 4566.67, 0, 675, 3425, 0),
(839, '8310', 425, 0, 0, 4, 0, 0, 425, 0, 0, 0, 0, 0, 425, 0, 0),
(841, '841', 0, 16933.3, 0, 4, 4, 0, 0, 8466.63, 0, 0, 8466.7, 0, 2268.75, 12700, 0),
(842, '842', 0, 836.333, 0, 4, 4, 0, 0, 836, 0, 0, 0.333313, 0, 212.5, 1255, 0),
(843, '843', 0, 5133.33, 0, 4, 4, 0, 0, 2567, 0, 0, 2566.33, 0, 425, 3850, 0),
(845, '845', 0, 4566.67, 0, 4, 4, 0, 0, 2283.34, 0, 0, 2283.33, 0, 675, 3425, 0),
(851, '852', 20000, 8466.7, 0, 4, 4, 0, 0, 8466.7, 0, 20000, 0, 0, 5000, 2116.68, 0),
(853, '855', 0, 2566.33, 0, 4, 4, 0, 0, 2566.33, 0, 0, 0, 0, 425, 3850, 0),
(855, '857', 0, 2283.33, 0, 4, 4, 0, 0, 2283.33, 0, 0, 0, 0, 675, 3425, 0),
(861, '862', 40000, 0, 0, 4, 4, 0, 0, 0, 0, 40000, 0, 0, 10000, 0, 0),
(881, '881', 0, 0, 30000, 0, 0, 4, 0, 0, 10000, 0, 0, 20000, 0, 0, 10000),
(891, '892', 0, 0, 20000, 0, 0, 4, 0, 0, 10000, 0, 0, 10000, 0, 0, 10000),
(901, '901', 0, 0, 10000, 0, 0, 4, 0, 0, 10000, 0, 0, 0, 0, 0, 10000),
(1001, '1001', 0, 0, 20000, 0, 0, 2, 0, 0, 10000, 0, 0, 10000, 0, 0, 10000),
(1011, '1011', 0, 0, 18000, 0, 0, 1, 0, 0, 18000, 0, 0, 0, 0, 0, 18000),
(1051, '1051', 24000, 26240, 0, 8, 8, 1, 3000, 3280, 0, 21000, 22960, 0, 3000, 3280, 0),
(1052, '1053', 5550, 0, 0, 4, 4, 0, 1387.5, 0, 0, 4162.5, 0, 0, 1387.5, 0, 0),
(1053, '1054', 5550, 32000, 0, 8, 8, 0, 693.75, 4000, 0, 4856.25, 28000, 0, 693.75, 4000, 0),
(1054, '10512', 3700, 0, 0, 4, 0, 0, 925, 0, 0, 2775, 0, 0, 925, 0, 0),
(1055, '1055', 0, 15480, 0, 4, 8, 0, 0, 1935, 0, 0, 13545, 0, 0, 1935, 0),
(1056, '1056', 3700, 4300, 0, 4, 8, 0, 925, 537.5, 0, 2775, 3762.5, 0, 925, 537.5, 0),
(1061, '10616', 22575, 35850, 0, 4, 8, 1, 0, 0, 0, 22575, 35850, 0, 5643.75, 4481.25, 0),
(1062, '1061', 4162.5, 0, 0, 4, 4, 0, 1387.5, 0, 0, 2775, 0, 0, 1387.5, 0, 0),
(1063, '1062', 4856.25, 28000, 0, 8, 8, 0, 693.75, 4000, 0, 4162.5, 24000, 0, 693.75, 4000, 0),
(1064, '1068', 2775, 2525, 0, 4, 7, 0, 308.33, 360.714, 0, 2466.67, 2164.29, 0, 693.75, 360.714, 0),
(1065, '1063', 0, 13545, 0, 4, 8, 0, 0, 1935, 0, 0, 11610, 0, 0, 1935, 0),
(1066, '1064', 2775, 3762.5, 0, 4, 8, 0, 925, 537.5, 0, 1850, 3225, 0, 925, 537.5, 0),
(1071, '1071', 22575, 35850, 0, 4, 8, 1, 2508.33, 3585, 0, 20066.7, 32265, 0, 5643.75, 4481.25, 0),
(1072, '1073', 2775, 6280, 0, 4, 8, 0, 346.88, 785, 0, 2428.12, 5495, 0, 693.75, 785, 0),
(1073, '1074', 4162.5, 24000, 0, 8, 8, 0, 693.75, 4000, 0, 3468.75, 20000, 0, 693.75, 4000, 0),
(1074, '10710', 2466.67, 2164.29, 0, 4, 7, 0, 274.07, 309.18, 0, 2192.6, 1855.11, 0, 693.75, 360.714, 0),
(1075, '1075', 0, 11610, 0, 4, 8, 0, 0, 1658.57, 0, 0, 9951.43, 0, 0, 1935, 0),
(1076, '1076', 1850, 3225, 0, 4, 8, 0, 616.67, 460.7, 0, 1233.33, 2764.3, 0, 925, 537.5, 0),
(1081, '1081', 20066.7, 32265, 0, 4, 8, 1, 2508.33, 3585, 0, 17558.3, 28680, 0, 5643.75, 4481.25, 0),
(1082, '1083', 2428.12, 5495, 0, 4, 8, 0, 303.52, 687, 0, 2124.6, 4808, 0, 693.75, 785, 0),
(1083, '1084', 3468.75, 20000, 0, 8, 8, 0, 0, 4000, 0, 3468.75, 16000, 0, 693.75, 4000, 0),
(1084, '10810', 2192.6, 1855.11, 0, 4, 7, 0, 274, 265.02, 0, 1918.6, 1590.09, 0, 693.75, 360.714, 0),
(1085, '1085', 0, 9951.43, 0, 4, 8, 0, 0, 1364.49, 0, 0, 8586.94, 0, 0, 1935, 0),
(1086, '1086', 1233.33, 2764.3, 0, 4, 8, 0, 411.11, 394.9, 0, 822.22, 2369.4, 0, 925, 537.5, 0),
(1091, '1091', 17558.3, 28680, 0, 4, 8, 1, 2194.79, 3187, 0, 15363.5, 25493, 0, 5643.75, 4481.25, 0),
(1092, '1093', 2124.6, 4808, 0, 4, 8, 0, 265.58, 601, 0, 1859.02, 4207, 0, 693.75, 785, 0),
(1093, '1094', 0, 16000, 0, 0, 8, 0, 0, 4000, 0, 0, 12000, 0, 0, 4000, 0),
(1094, '10911', 1918.6, 1590.09, 0, 4, 7, 0, 239.75, 227.16, 0, 1678.85, 1362.93, 0, 693.75, 360.714, 0),
(1095, '1095', 7600, 21626.9, 0, 8, 8, 0, 950, 2703.37, 0, 6650, 18923.6, 0, 950, 2703.37, 0),
(1096, '1096', 822.22, 2369.4, 0, 4, 8, 0, 274.07, 338.5, 0, 548.15, 2030.9, 0, 925, 537.5, 0),
(1101, '1101', 15363.5, 25493, 0, 4, 8, 1, 2194.79, 3642, 0, 13168.8, 21851, 0, 5643.75, 4481.25, 0),
(1102, '1103', 1859.02, 4207, 0, 4, 8, 0, 265.58, 601, 0, 1593.44, 3606, 0, 693.75, 785, 0),
(1103, '1104', 0, 12000, 0, 0, 8, 0, 0, 4000, 0, 0, 8000, 0, 0, 4000, 0),
(1104, '11011', 1678.85, 1362.93, 0, 4, 7, 0, 239.75, 227.16, 0, 1439.1, 1135.77, 0, 693.75, 360.714, 0),
(1105, '1105', 6650, 18923.6, 0, 8, 8, 0, 950, 2703.37, 0, 5700, 16220.2, 0, 950, 2703.37, 0),
(1106, '1106', 548.15, 2030.9, 0, 4, 8, 0, 274.08, 406.2, 0, 274.07, 1624.7, 0, 925, 537.5, 0),
(1111, '1111', 13168.8, 21851, 0, 4, 8, 1, 2194.79, 3642, 0, 10974, 18209, 0, 5643.75, 4481.25, 0),
(1112, '1113', 1593.44, 3606, 0, 4, 8, 0, 318.69, 721, 0, 1274.75, 2885, 0, 693.75, 785, 0),
(1113, '1114', 0, 8000, 0, 0, 8, 0, 0, 4000, 0, 0, 4000, 0, 0, 4000, 0),
(1114, '11111', 1439.1, 1135.77, 0, 4, 7, 0, 287.7, 227.16, 0, 1151.4, 908.606, 0, 693.75, 360.714, 0),
(1115, '1115', 5700, 16220.2, 0, 8, 8, 0, 1140, 2703.37, 0, 4560, 13516.8, 0, 950, 2703.37, 0),
(1116, '1116', 274.07, 1624.7, 0, 4, 8, 0, 137.04, 324.9, 0, 137.03, 1299.8, 0, 925, 537.5, 0),
(1121, '1121', 10974, 18209, 0, 4, 8, 1, 2194.79, 3642, 0, 8779.18, 14567, 0, 5643.75, 4481.25, 0),
(1122, '1123', 1274.75, 2885, 0, 4, 8, 0, 424.92, 721, 0, 849.83, 2164, 0, 693.75, 785, 0),
(1123, '1124', 0, 4000, 0, 0, 8, 0, 0, 4000, 0, 0, 0, 0, 0, 4000, 0),
(1124, '11210', 1151.4, 908.606, 0, 4, 7, 0, 383.6, 454.31, 0, 767.8, 454.296, 0, 693.75, 360.714, 0),
(1125, '1125', 4560, 13516.8, 0, 8, 8, 0, 1140, 2703.37, 0, 3420, 10813.5, 0, 950, 2703.37, 0),
(1126, '1126', 137.03, 1299.8, 0, 4, 8, 0, 137.03, 649.9, 0, 0, 649.9, 0, 0, 537.5, 0),
(7810, '7811', 1700, 0, 0, 4, 0, 0, 425, 0, 0, 1275, 0, 0, 425, 0, 0),
(7815, '781', 10200, 0, 0, 4, 0, 0, 2550, 0, 0, 7650, 0, 0, 2550, 0, 0),
(7816, '786', 1900, 0, 0, 4, 0, 0, 475, 0, 0, 1425, 0, 0, 475, 0, 0),
(7818, '788', 3600, 0, 0, 4, 0, 0, 900, 0, 0, 2700, 0, 0, 900, 0, 0),
(7824, '7816', 6800, 0, 0, 4, 0, 0, 1700, 0, 0, 5100, 0, 0, 1700, 0, 0),
(7910, '7913', 1275, 1540, 0, 4, 4, 0, 0, 256.67, 0, 1275, 1283.33, 0, 318.75, 385, 0),
(7915, '792', 7650, 0, 0, 4, 0, 0, 0, 0, 0, 7650, 0, 0, 1912.5, 0, 0),
(7916, '799', 1425, 0, 0, 4, 0, 0, 475, 0, 0, 950, 0, 0, 356.25, 0, 0),
(7918, '7910', 2700, 1230, 0, 4, 4, 0, 900, 205, 0, 1800, 1025, 0, 675, 307.5, 0),
(7922, '7918', 0, 10960, 0, 0, 4, 0, 0, 1826.67, 0, 0, 9133.33, 0, 0, 2740, 0),
(8016, '807', 950, 0, 0, 4, 0, 0, 475, 0, 0, 475, 0, 0, 356.25, 0, 0),
(8017, '808', 0, 1602, 0, 0, 4, 0, 0, 1602, 0, 0, 0, 0, 0, 400.5, 0),
(8110, '8112', 1275, 1283.33, 0, 4, 4, 0, 0, 256.6, 0, 1275, 1026.73, 0, 318.75, 385, 0),
(8115, '813', 7650, 0, 0, 4, 0, 0, 5100, 0, 0, 2550, 0, 0, 1912.5, 0, 0),
(8118, '819', 1800, 1025, 0, 4, 4, 0, 900, 205, 0, 900, 820, 0, 675, 307.5, 0),
(8210, '8215', 1275, 1026.73, 0, 4, 4, 0, 425, 256.73, 0, 850, 770, 0, 318.75, 385, 0),
(8215, '823', 2550, 0, 0, 4, 0, 0, 2550, 0, 0, 0, 0, 0, 1912.5, 0, 0),
(8216, '8210', 475, 0, 0, 4, 0, 0, 475, 0, 0, 0, 0, 0, 356.25, 0, 0),
(8222, '8217', 0, 9133.33, 0, 0, 4, 0, 0, 1827.33, 0, 0, 7306, 0, 0, 2740, 0),
(8226, '8216', 3600, 0, 0, 4, 0, 0, 900, 0, 0, 2700, 0, 0, 900, 0, 0),
(8310, '835', 850, 770, 0, 4, 4, 0, 850, 257, 0, 0, 513, 0, 318.75, 385, 0),
(8315, '8316', 3000, 0, 0, 1, 0, 0, 3000, 0, 0, 0, 0, 0, 3000, 0, 0),
(8318, '837', 3620, 820, 0, 4, 4, 0, 905, 205, 0, 2715, 615, 0, 905, 205, 0),
(8410, '8411', 0, 513, 0, 4, 4, 0, 0, 257, 0, 0, 256, 0, 318.75, 385, 0),
(8418, '849', 2715, 615, 0, 4, 4, 0, 905, 205, 0, 1810, 410, 0, 905, 205, 0),
(8422, '8414', 0, 7306, 0, 0, 4, 0, 0, 1827, 0, 0, 5479, 0, 0, 2740, 0),
(8510, '8510', 0, 256, 0, 4, 4, 0, 0, 256, 0, 0, 0, 0, 318.75, 385, 0),
(8522, '8512', 0, 5479, 0, 0, 4, 0, 0, 1826.67, 0, 0, 3652.33, 0, 0, 2740, 0),
(8526, '8511', 2700, 0, 0, 4, 0, 0, 900, 0, 0, 1800, 0, 0, 900, 0, 0),
(8618, '869', 905, 410, 0, 4, 4, 0, 905, 205, 0, 0, 205, 0, 0, 205, 0),
(8622, '8614', 0, 3652, 0, 0, 4, 0, 0, 1826, 0, 0, 1826, 0, 0, 2740, 0),
(8626, '8613', 1800, 0, 0, 4, 0, 0, 900, 0, 0, 900, 0, 0, 900, 0, 0),
(8824, '8815', 1240, 0, 0, 4, 0, 0, 1240, 0, 0, 0, 0, 0, 0, 0, 0),
(10510, '1058', 0, 3900, 0, 4, 8, 0, 0, 487.5, 0, 0, 3412.5, 0, 0, 487.5, 0),
(10512, '1057', 1850, 0, 0, 4, 0, 0, 462.5, 0, 0, 1387.5, 0, 0, 462.5, 0, 0),
(10514, '10513', 5500, 0, 0, 4, 0, 0, 1375, 0, 0, 4125, 0, 0, 1375, 0, 0),
(10515, '1052', 9200, 0, 0, 4, 0, 0, 2300, 0, 0, 5100, 0, 0, 2300, 0, 0),
(10518, '10514', 0, 6560, 0, 4, 8, 0, 0, 820, 0, 0, 5740, 0, 0, 820, 0),
(10522, '10511', 0, 14575, 0, 0, 8, 0, 0, 1821.88, 0, 0, 12753.1, 0, 0, 1821.88, 0),
(10610, '1066', 0, 3412.5, 0, 4, 8, 0, 0, 487.5, 0, 0, 2925, 0, 0, 487.5, 0),
(10613, '10613', 5500, 13150, 0, 10, 10, 0, 550, 1315, 0, 4950, 11835, 0, 550, 1315, 0),
(10614, '1069', 4125, 13150, 0, 4, 10, 0, 412.5, 1316, 0, 3712.5, 11834, 0, 1031.25, 1315, 0),
(10618, '10610', 0, 5740, 0, 4, 8, 0, 0, 820, 0, 0, 4920, 0, 0, 820, 0),
(10714, '10711', 3712.5, 11834, 0, 4, 10, 0, 1237.83, 0, 0, 2474.67, 11834, 0, 1031.25, 1315, 0),
(10715, '1072', 5100, 0, 0, 4, 0, 0, 1700, 0, 0, 3400, 0, 0, 2300, 0, 0),
(10718, '10712', 0, 4920, 0, 4, 8, 0, 0, 820, 0, 0, 4100, 0, 0, 820, 0),
(10722, '1079', 0, 14575, 0, 0, 8, 0, 0, 1821.88, 0, 0, 12753.1, 0, 0, 3416.04, 0),
(10810, '1087', 0, 2925, 0, 4, 8, 0, 0, 487.5, 0, 0, 2437.5, 0, 0, 487.5, 0),
(10813, '10813', 4950, 11835, 0, 10, 10, 0, 495, 1183.5, 0, 4455, 10651.5, 0, 550, 1315, 0),
(10814, '10811', 2474.67, 11834, 0, 4, 10, 0, 0, 1479.38, 0, 2474.67, 10354.6, 0, 1031.25, 1315, 0),
(10815, '1082', 3400, 0, 0, 4, 0, 0, 1700, 0, 0, 1700, 0, 0, 2300, 0, 0),
(10818, '10812', 0, 4100, 0, 4, 8, 0, 0, 820, 0, 0, 3280, 0, 0, 820, 0),
(10822, '1089', 0, 12753.1, 0, 0, 8, 0, 0, 1821.88, 0, 0, 10931.3, 0, 0, 3416.04, 0),
(10910, '1098', 0, 2437.5, 0, 4, 8, 0, 0, 487.5, 0, 0, 1950, 0, 0, 487.5, 0),
(10914, '10912', 3712.5, 0, 0, 3, 0, 0, 1237.5, 0, 0, 2475, 0, 0, 1237.5, 0, 0),
(10915, '1092', 1700, 0, 0, 4, 0, 0, 1700, 0, 0, 0, 0, 0, 2300, 0, 0),
(10918, '10913', 4200, 9200, 0, 8, 8, 0, 525, 1150, 0, 3675, 8050, 0, 525, 1150, 0),
(10922, '10910', 0, 10931.3, 0, 0, 8, 0, 0, 1821.88, 0, 0, 9109.38, 0, 0, 3416.04, 0),
(11010, '1108', 0, 1950, 0, 4, 8, 0, 0, 487.5, 0, 0, 1462.5, 0, 0, 487.5, 0),
(11013, '11015', 4455, 10651.5, 0, 10, 10, 0, 636.43, 1521.64, 0, 3818.57, 9129.86, 0, 550, 1315, 0),
(11014, '11012', 2475, 10355.6, 0, 3, 7, 0, 0, 1479.38, 0, 2475, 8876.25, 0, 825, 10355.6, 0),
(11018, '11013', 3675, 8050, 0, 8, 8, 0, 459.38, 1006, 0, 3215.62, 7044, 0, 525, 1150, 0),
(11022, '11010', 0, 9109.38, 0, 0, 8, 0, 0, 1821.88, 0, 0, 7287.5, 0, 0, 3416.04, 0),
(11110, '1118', 0, 1462.5, 0, 4, 8, 0, 0, 487.5, 0, 0, 975, 0, 0, 487.5, 0),
(11114, '11112', 2475, 8876.25, 0, 3, 7, 0, 495, 0, 0, 1980, 8876.25, 0, 825, 10355.6, 0),
(11118, '11113', 3215.62, 7044, 0, 8, 8, 0, 459.38, 880, 0, 2756.24, 6164, 0, 525, 1150, 0),
(11122, '11110', 0, 7287.5, 0, 0, 8, 0, 0, 1821.88, 0, 0, 5465.62, 0, 0, 3416.04, 0),
(11210, '1128', 0, 975, 0, 4, 8, 0, 0, 975, 0, 0, 0, 0, 0, 487.5, 0),
(11213, '11213', 3818.57, 9129.86, 0, 10, 10, 0, 763.71, 1825.97, 0, 3054.86, 7303.89, 0, 550, 1315, 0),
(11214, '11211', 1980, 8876.25, 0, 3, 7, 0, 0, 1775.2, 0, 1980, 7101.05, 0, 825, 10355.6, 0),
(11222, '1129', 0, 5465.62, 0, 0, 8, 0, 0, 1821.88, 0, 0, 3643.74, 0, 0, 3416.04, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productores`
--

DROP TABLE IF EXISTS `productores`;
CREATE TABLE `productores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) DEFAULT '',
  `edad` int(2) DEFAULT 0,
  `telefono` varchar(12) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT '',
  `no_cuenta` varchar(20) DEFAULT NULL,
  `estado` int(2) DEFAULT 1,
  `foto` varchar(155) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `productores`
--

INSERT INTO `productores` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `estado`, `foto`) VALUES
(1, 'LUIS', 'E', 'TORRES', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'NAIN', 'PEREZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'SANTIAGO', 'ALMEIDA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'BISMAR', 'LAZARO', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'JESUS', 'PALMA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'ROBERTO', 'MARQUEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(7, 'ULDARIO', 'SANCHEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(8, 'JOSE', 'DE LA LUZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'GENARO', 'COLORADO', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'LAZARO', 'MIRANDA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(11, 'JOSE ANTONIO', 'ARIAS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(12, 'DANIEL JESUS', 'SEGURA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(13, 'MARCOS', 'OCHOA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(14, 'ADALBERTO', 'MARTINEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(15, 'SANTIAGO', 'LUNA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(16, 'ALBIN', 'SANCHEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(17, 'NAIN', 'CALIX', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(18, 'CIRILO', 'MORALES', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(19, 'NOE', 'RIVERA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(20, 'GAMALIEL', 'SANCHEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(21, 'FEDERICO', 'REGLA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(22, 'BERNAVE', 'RAMOS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(23, 'INOCENTE', 'CALIX', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(24, 'ANDRES', 'ESTRADA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(25, 'ADONAY', 'ARIAS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(26, 'OSEAS', 'SANCHEZ', '', 0, '', '', ' ', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(27, 'JOSE MANUEL', 'GARCIA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(28, 'MANACE', 'CALIX', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(29, 'EZEQUIEL', 'MARTINEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(30, 'RAYMUNDO', 'CAMPOS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(31, 'PRADO', 'VERDE', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(32, 'ANTONIO', 'HERNANDEZ', 'BISMAR', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(33, 'TOMAS', 'MORALES', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(34, 'AUDELIN', 'MARTINEZ', 'MARIN', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(35, 'MIGUEL', 'NARANJO', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(36, 'JUAN DANIEL', 'HERNANDEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(37, 'CARLOS', 'TORRES', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(38, 'ARTURO', 'IZQUIERDO', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(39, 'JOSE AARON', 'BRIO', 'FRIAS', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(40, 'CARLOS', 'TECUM', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(41, 'ARMANDO', 'ALMEIDA', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(42, 'NELSON', 'DE LOS SANTOS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(44, 'FLORENTINO  ', 'MARTINEZ', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(45, 'YOVANI   ', 'ARIAS', '', 0, '', '', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productor_fruta`
--

DROP TABLE IF EXISTS `productor_fruta`;
CREATE TABLE `productor_fruta` (
  `id` varchar(11) NOT NULL,
  `id_fruta` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `peso` float NOT NULL,
  `foto` varchar(200) NOT NULL,
  `fecha_compra` date DEFAULT NULL,
  `hora_compra` varchar(15) NOT NULL DEFAULT '00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `productor_fruta`
--

INSERT INTO `productor_fruta` (`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`, `hora_compra`) VALUES
('1001', '1001', 7065.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:34:51'),
('10010', '10010', 4228, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:36:46'),
('10011', '10011', 3340.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:36:58'),
('10012', '10012', 2174, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:37:12'),
('10013', '10013', 1194.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:37:37'),
('1002', '1002', 4585.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:02'),
('1003', '1003', 2572.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:13'),
('1004', '1004', 8016.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:24'),
('1005', '1005', 6712.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:36'),
('1006', '1006', 3155.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:46'),
('1007', '1007', 1041.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:35:58'),
('1008', '1008', 1314.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:36:10'),
('1009', '1009', 1409.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-17', '12:36:34'),
('1011', '1011', 8596.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:07:32'),
('10110', '10110', 1127.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:10:03'),
('10111', '10111', 2453.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:10:29'),
('10112', '10112', 1762.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:10:46'),
('10113', '10113', 2828.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:11:01'),
('10114', '10114', 1545, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:11:16'),
('10115', '1013', 1037.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:11:35'),
('10116', '10115', 1830.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:20:59'),
('10117', '1011', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:53:05'),
('10118', '1012', 1633, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '17:52:57'),
('1012', '1012', 2328.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:07:49'),
('1013', '1013', 2375.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:08:03'),
('1014', '1014', 6343.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:08:18'),
('1015', '1015', 5090.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:08:43'),
('1016', '1016', 1690.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:08:59'),
('1017', '1017', 974.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:09:11'),
('1018', '1018', 2664.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:09:24'),
('1019', '1019', 914, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-18', '13:09:43'),
('1021', '1021', 7072, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:54:13'),
('10210', '10210', 1796.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:56:09'),
('10211', '10211', 2442.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:56:20'),
('10212', '10212', 8048.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:58:42'),
('10213', '10213', 569.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:58:58'),
('1022', '1022', 3629, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:54:24'),
('1023', '1023', 2097, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:54:39'),
('1024', '1024', 6067.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:54:49'),
('1025', '1025', 5186.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:55:01'),
('1026', '1026', 2560.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:55:13'),
('1027', '1027', 2488.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:55:24'),
('1028', '1028', 2443.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:55:39'),
('1029', '1029', 3214.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-19', '13:55:58'),
('1031', '1031', 8628, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:57:37'),
('10310', '10310', 5284.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:00:17'),
('10311', '10311', 2085.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:00:30'),
('10312', '10312', 1663, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:00:42'),
('10313', '10313', 776.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:00:56'),
('10314', '10314', 1143.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:01:19'),
('10315', '10315', 1017.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '18:01:34'),
('1032', '1032', 3404.3, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:58:01'),
('1033', '1033', 3664, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:58:12'),
('1034', '1034', 5532.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:58:24'),
('1035', '1035', 5653.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:58:36'),
('1036', '1036', 3311.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:59:09'),
('1037', '1037', 1027, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:59:30'),
('1038', '1038', 1560, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:59:46'),
('1039', '1039', 3023.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-20', '17:59:58'),
('1041', '1041', 6950.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:24:26'),
('10410', '10410', 1514.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:27:00'),
('10411', '10411', 6052.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:27:43'),
('10412', '10412', 2102.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:28:01'),
('10413', '10413', 309.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:28:14'),
('10414', '10414', 1836.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:28:35'),
('1042', '1042', 3823, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:24:44'),
('1043', '1043', 6325.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:25:11'),
('1044', '1044', 5793.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:25:21'),
('1045', '1045', 3109.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:25:53'),
('1046', '1046', 2425.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:26:07'),
('1047', '1047', 2336.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:26:19'),
('1048', '1048', 3028.3, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:26:35'),
('1049', '1049', 1855.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-21', '18:26:46'),
('1051', '1051', 7154.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:11:28'),
('10510', '10510', 1058, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:14:12'),
('10511', '10511', 3004, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:14:24'),
('10512', '10512', 3346.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:14:36'),
('10513', '10513', 5250.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:14:50'),
('10514', '10514', 2231.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:15:03'),
('10515', '10515', 2900.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:15:16'),
('10516', '10516', 390.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:16:13'),
('1052', '1052', 4429.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:12:07'),
('1053', '1053', 2047.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:12:28'),
('1054', '1054', 4196.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:12:40'),
('1055', '1055', 5435.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:12:57'),
('1056', '1056', 1935, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:13:08'),
('1057', '1057', 1223.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:13:24'),
('1058', '1058', 1430.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:13:40'),
('1059', '1059', 1598.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-24', '19:13:51'),
('1061', '10616', 6902, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:42:35'),
('10610', '1069', 4989.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:46:10'),
('10611', '10610', 2188.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:46:22'),
('10612', '10611', 2076.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:46:35'),
('10613', '10612', 884.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:46:56'),
('10614', '10613', 4344, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:47:25'),
('10615', '10614', 1176.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:48:21'),
('10616', '10615', 2568.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:48:37'),
('1062', '1061', 4055.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:42:45'),
('1063', '1062', 4723.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:42:56'),
('1064', '1063', 4382.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:43:07'),
('1065', '1064', 2724.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:43:28'),
('1066', '1065', 883.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:43:45'),
('1067', '1066', 2001, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:43:58'),
('1068', '1067', 1039.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:44:09'),
('1069', '1068', 2845.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-31', '19:44:28'),
('1071', '1071', 7043.3, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:28:30'),
('10710', '10710', 2976.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:30:46'),
('10711', '10711', 5372.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:31:08'),
('10712', '10712', 2142.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:31:18'),
('10713', '10713', 1917, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:31:31'),
('1072', '1072', 4146.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:28:40'),
('1073', '1073', 3064.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:28:50'),
('1074', '1074', 6092.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:29:00'),
('1075', '1075', 7309.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:29:11'),
('1076', '1076', 2327.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:29:21'),
('1077', '1077', 732.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:29:39'),
('1078', '1078', 570.3, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:30:06'),
('1079', '1079', 4329.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-07', '20:30:29'),
('1081', '1081', 8662.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:45:48'),
('10810', '10810', 3083, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:47:26'),
('10811', '10811', 4532.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:47:59'),
('10812', '10812', 2189.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:48:11'),
('10813', '10813', 3391.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:48:32'),
('10814', '1081', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '21:12:05'),
('10815', '1082', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '21:12:18'),
('1082', '1082', 3591.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:45:59'),
('1083', '1083', 4026.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:46:08'),
('1084', '1084', 6163, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:46:21'),
('1085', '1085', 4049.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:46:31'),
('1086', '1086', 3064.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:46:40'),
('1087', '1087', 1590.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:46:55'),
('1088', '1088', 1894.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:47:05'),
('1089', '1089', 2999.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-12', '20:47:16'),
('1091', '1091', 6036.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:50:09'),
('10910', '10910', 3256.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:52:07'),
('10911', '10911', 2876, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:52:19'),
('10912', '10912', 5339.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:52:31'),
('10913', '10913', 2167.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:52:42'),
('10914', '10914', 967, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:52:56'),
('10915', '10915', 350.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:53:12'),
('10916', '10916', 356.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '18:07:18'),
('1092', '1092', 5081.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:50:21'),
('1093', '1093', 4036.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:50:32'),
('1094', '1094', 7537.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:50:42'),
('1095', '1095', 4805, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:50:58'),
('1096', '1096', 2906, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:51:09'),
('1097', '1097', 1467.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:51:23'),
('1098', '1098', 1275.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:51:36'),
('1099', '1099', 703, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-14', '17:51:56'),
('1101', '1101', 6019.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:14:52'),
('11010', '11010', 3482.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:17:08'),
('11011', '11011', 2723.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:17:23'),
('11012', '11012', 4497.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:17:38'),
('11013', '11013', 3788, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:17:52'),
('11014', '11014', 425, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:18:03'),
('11015', '11015', 3716, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:18:21'),
('1102', '1102', 2336.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:15:03'),
('1103', '1103', 4073.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:15:17'),
('1104', '1104', 7019.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:15:26'),
('1105', '1105', 3863.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:16:07'),
('1106', '1106', 2485.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:16:20'),
('1107', '1107', 1109.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:16:32'),
('1108', '1108', 1118.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:16:46'),
('1109', '1109', 1551.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-21', '21:16:56'),
('1111', '1111', 9966.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:34:33'),
('11110', '11110', 1516, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:37:21'),
('11111', '11111', 2987.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:37:31'),
('11112', '11112', 5404.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:37:43'),
('11113', '11113', 2143.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:37:56'),
('11114', '11114', 682, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:38:12'),
('11115', '11115', 522.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:38:22'),
('1112', '1112', 3335.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:34:45'),
('1113', '1113', 3996.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:35:01'),
('1114', '1114', 6964, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:35:20'),
('1115', '1115', 4064.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:35:34'),
('1116', '1116', 2833.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:36:00'),
('1117', '1117', 1074.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:36:40'),
('1118', '1118', 1983.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:36:52'),
('1119', '1119', 1328, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-09-28', '21:37:03'),
('1121', '1121', 10920.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:02:36'),
('11210', '11210', 2803.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:04:27'),
('11211', '11211', 4423.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:04:40'),
('11212', '11212', 511.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:04:52'),
('11213', '11213', 4008, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:05:06'),
('1122', '1122', 3160.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:02:52'),
('1123', '1123', 4117, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:03:04'),
('1124', '1124', 6139, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:03:13'),
('1125', '1125', 3858.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:03:24'),
('1126', '1126', 2700.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:03:34'),
('1127', '1127', 1242.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:03:49'),
('1128', '1128', 2534.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:04:03'),
('1129', '1129', 3094.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-05', '17:04:17'),
('1131', '1131', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:19:58'),
('11310', '11310', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:21:47'),
('11311', '11311', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:22:02'),
('11312', '11312', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:22:13'),
('11313', '11313', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:22:22'),
('11314', '1132', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:17:57'),
('11315', '1131', 10800, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:21:14'),
('11316', '1132', 2092.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:21:51'),
('11317', '1133', 3025.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:22:18'),
('11318', '1134', 6090.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:22:33'),
('11319', '11310', 3507, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:22:50'),
('1132', '1132', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:20:08'),
('11320', '1135', 3054, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:23:20'),
('11321', '1136', 3205.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:23:45'),
('11322', '11314', 4060, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:23:59'),
('11323', '11315', 1686.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:24:26'),
('11324', '1138', 1940.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:24:51'),
('11325', '1137', 978.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:25:15'),
('11326', '11316', 482, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:25:32'),
('11327', '1139', 2997.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:25:58'),
('11328', '11311', 4025, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:26:12'),
('11329', '11312', 571.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '12:26:30'),
('1133', '1133', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:20:18'),
('1134', '1134', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:20:26'),
('1135', '1135', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:20:37'),
('1136', '1136', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:20:50'),
('1137', '1137', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:21:03'),
('1138', '1138', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:21:16'),
('1139', '1139', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-12', '17:21:34'),
('1141', '1141', 14135.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:33:49'),
('11410', '11410', 587, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:36:48'),
('11411', '11411', 2026.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:37:16'),
('11412', '11412', 692.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:37:37'),
('11413', '11411', 0, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:37:55'),
('11414', '11413', 381, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:38:51'),
('11415', '11413', -381, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:55:17'),
('11416', '11414', 4765.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:59:22'),
('11417', '11411', 1136, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '12:00:43'),
('1142', '1142', 5804.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:34:09'),
('1143', '1143', 4101.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:34:23'),
('1144', '1144', 2777.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:34:46'),
('1145', '1145', 2572.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:35:08'),
('1146', '1146', 2911.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:35:30'),
('1147', '1147', 2005.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:35:51'),
('1148', '1148', 654.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:36:17'),
('1149', '1149', 2070.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-07', '11:36:34'),
('1151', '1151', 13473.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:33:41'),
('11510', '11510', 995.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:39:40'),
('11511', '11511', 384.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:40:36'),
('11512', '11512', 2797.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:41:08'),
('11513', '11513', 4156.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:41:53'),
('11514', '11514', 486.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:42:38'),
('1152', '1152', 5393.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:34:41'),
('1153', '1153', 2510.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:35:06'),
('1154', '1154', 5350, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:37:14'),
('1155', '1155', 2009.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:37:33'),
('1156', '1156', 3085.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:37:54'),
('1157', '1157', 2554.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:38:20'),
('1158', '1158', 2007.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:38:38'),
('1159', '1159', 2988, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-14', '17:38:59'),
('1161', '1161', 14201.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:23:43'),
('11610', '11610', 1304.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:30:41'),
('11611', '11611', 1872.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:31:49'),
('11612', '11612', 2102.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:32:03'),
('11613', '11613', 379.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:32:28'),
('11614', '11614', 357, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:32:56'),
('1162', '1162', 6101.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:25:47'),
('1163', '1163', 2520, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:26:04'),
('1164', '1164', 2132.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:26:19'),
('1165', '1165', 3217.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:26:37'),
('1166', '1166', 6127.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:28:19'),
('1167', '1167', 3468.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:28:36'),
('1168', '1168', 1810, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:29:14'),
('1169', '1169', 3369.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-21', '18:30:20'),
('1171', '1171', 13983.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:01:32'),
('11710', '11710', 1207.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:04:36'),
('11711', '11711', 4165, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:04:54'),
('11712', '11712', 3890.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:05:20'),
('11713', '11713', 606.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:05:43'),
('1172', '1172', 4661.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:01:53'),
('1173', '1173', 2333.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:02:15'),
('1174', '1174', 5594.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:02:36'),
('1175', '1175', 3308.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:02:58'),
('1176', '1176', 3081, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:03:14'),
('1177', '1177', 1468.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:03:36'),
('1178', '1178', 2007, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:03:52'),
('1179', '1179', 2989.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-10-28', '20:04:18'),
('1181', '1181', 1840, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:34:18'),
('11810', '11810', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-09-42-21-118_11.png', '2020-11-04', '09:42:21'),
('11811', '11810', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-09-42-27-118_11.png', '2020-11-04', '09:42:27'),
('11812', '11810', 221.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-09-42-32-118_11.png', '2020-11-04', '09:42:32'),
('11813', '11810', 220.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-09-49-27-118_11.png', '2020-11-04', '09:49:27'),
('11814', '1181', 275.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-09-58-51-118_1.png', '2020-11-04', '09:58:51'),
('11815', '1181', 251.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-01-57-118_1.png', '2020-11-04', '10:01:57'),
('11816', '1181', 284.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-06-21-118_1.png', '2020-11-04', '10:06:21'),
('11817', '1181', 241.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-11-11-118_1.png', '2020-11-04', '10:11:11'),
('11818', '1181', 274.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-16-23-118_1.png', '2020-11-04', '10:16:23'),
('11819', '1181', 244.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-20-50-118_1.png', '2020-11-04', '10:20:50'),
('1182', '1182', 1853.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:34:32'),
('11820', '1181', 270.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-25-51-118_1.png', '2020-11-04', '10:25:51'),
('11821', '1181', 187.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-10-29-12-118_1.png', '2020-11-04', '10:29:12'),
('11822', '1181', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-03-37-118_1.png', '2020-11-04', '12:03:37'),
('11823', '11811', 203.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-03-52-118_19.png', '2020-11-04', '12:03:52'),
('11824', '11811', 214.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-07-16-118_19.png', '2020-11-04', '12:07:16'),
('11825', '11811', 220.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-10-05-118_19.png', '2020-11-04', '12:10:05'),
('11826', '11811', 162.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-12-17-118_19.png', '2020-11-04', '12:12:17'),
('11827', '11811', 251.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-18-14-118_19.png', '2020-11-04', '12:18:14'),
('11828', '11811', 244, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-21-15-118_19.png', '2020-11-04', '12:21:15'),
('11829', '11811', 252, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-24-18-118_19.png', '2020-11-04', '12:24:18'),
('1183', '1183', 2422.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:34:47'),
('11830', '11811', 205.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-27-01-118_19.png', '2020-11-04', '12:27:01'),
('11831', '11811', 90.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-28-10-118_19.png', '2020-11-04', '12:28:10'),
('11832', '11812', 261.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-38-35-118_15.png', '2020-11-04', '12:38:35'),
('11833', '11812', 287.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-44-02-118_15.png', '2020-11-04', '12:44:02'),
('11834', '11812', 283.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-47-46-118_15.png', '2020-11-04', '12:47:46'),
('11835', '11812', 270.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-51-34-118_15.png', '2020-11-04', '12:51:34'),
('11836', '11812', 283.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-12-56-56-118_15.png', '2020-11-04', '12:56:56'),
('11837', '11812', 269, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-01-24-118_15.png', '2020-11-04', '13:01:24'),
('11838', '11812', 335, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-06-45-118_15.png', '2020-11-04', '13:06:45'),
('11839', '11812', 246.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-12-20-118_15.png', '2020-11-04', '13:12:20'),
('1184', '1184', 1262.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:35:06'),
('11840', '11812', 262, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-16-20-118_15.png', '2020-11-04', '13:16:20'),
('11841', '11812', 239.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-21-12-118_15.png', '2020-11-04', '13:21:12'),
('11842', '11812', 268, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-26-33-118_15.png', '2020-11-04', '13:26:33'),
('11843', '11812', 233.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-33-46-118_15.png', '2020-11-04', '13:33:46'),
('11844', '11812', 259.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-38-50-118_15.png', '2020-11-04', '13:38:50'),
('11845', '11812', 248.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-46-11-118_15.png', '2020-11-04', '13:46:11'),
('11846', '11812', 297.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-13-51-04-118_15.png', '2020-11-04', '13:51:04'),
('11847', '1181', 255.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-02-28-118_1.png', '2020-11-04', '14:02:28'),
('11848', '1181', 236.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-08-13-118_1.png', '2020-11-04', '14:08:13'),
('11849', '1181', 265, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-13-55-118_1.png', '2020-11-04', '14:13:55'),
('1185', '1185', 2551.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:35:22'),
('11850', '1181', 237.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-18-28-118_1.png', '2020-11-04', '14:18:28'),
('11851', '1181', 266.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-22-01-118_1.png', '2020-11-04', '14:22:01'),
('11852', '1181', 265.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-27-07-118_1.png', '2020-11-04', '14:27:07'),
('11853', '1181', 247.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-31-57-118_1.png', '2020-11-04', '14:31:57'),
('11854', '1181', 274.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-14-35-11-118_1.png', '2020-11-04', '14:35:11'),
('11855', '11813', 603.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-08-37-118_26.png', '2020-11-04', '15:08:37'),
('11856', '1181', 274.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-42-28-118_1.png', '2020-11-04', '15:42:28'),
('11857', '1181', 231.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-45-36-118_1.png', '2020-11-04', '15:45:36'),
('11858', '1181', 250.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-49-06-118_1.png', '2020-11-04', '15:49:06'),
('11859', '1181', 271.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-53-05-118_1.png', '2020-11-04', '15:53:05'),
('1186', '1186', 3374, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:35:37'),
('11860', '1181', 225.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-56-04-118_1.png', '2020-11-04', '15:56:04'),
('11861', '1181', 130.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-15-57-44-118_1.png', '2020-11-04', '15:57:44'),
('11862', '1181', 277.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-21-27-118_1.png', '2020-11-04', '16:21:27'),
('11863', '1181', 273, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-24-14-118_1.png', '2020-11-04', '16:24:14'),
('11864', '1181', 243.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-27-55-118_1.png', '2020-11-04', '16:27:55'),
('11865', '1181', 293, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-31-28-118_1.png', '2020-11-04', '16:31:28'),
('11866', '1181', 247, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-35-09-118_1.png', '2020-11-04', '16:35:09'),
('11867', '1181', 288.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-39-02-118_1.png', '2020-11-04', '16:39:02'),
('11868', '1181', 257.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-42-58-118_1.png', '2020-11-04', '16:42:58'),
('11869', '1181', 305.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-47-05-118_1.png', '2020-11-04', '16:47:05'),
('1187', '1187', 2543.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:35:55'),
('11870', '1181', 246.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-49-57-118_1.png', '2020-11-04', '16:49:57'),
('11871', '1181', 292.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-53-51-118_1.png', '2020-11-04', '16:53:51'),
('11872', '1181', 285, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-16-57-20-118_1.png', '2020-11-04', '16:57:20'),
('11873', '1181', 249.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-00-18-118_1.png', '2020-11-04', '17:00:18'),
('11874', '1181', 233.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-04-48-118_1.png', '2020-11-04', '17:04:48'),
('11875', '1181', 266.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-08-58-118_1.png', '2020-11-04', '17:08:58'),
('11876', '1181', 273.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-15-00-118_1.png', '2020-11-04', '17:15:00'),
('11877', '1181', 272.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-19-16-118_1.png', '2020-11-04', '17:19:16'),
('11878', '1181', 134.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-04-17-20-49-118_1.png', '2020-11-04', '17:20:49'),
('11879', '11812', 1, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:38:29'),
('1188', '1188', 3311.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:36:17'),
('11880', '11814', 2325.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:39:01'),
('11881', '11815', 501.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:39:21'),
('11882', '11816', 3838.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:39:47'),
('11883', '1181', 268, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:41:16'),
('11884', '1181', 1428.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '13:48:22'),
('1189', '1189', 5349.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-03', '07:36:42'),
('1191', '1191', 13851.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:50:04'),
('11910', '11910', 2500.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:53:56'),
('11911', '11911', 1999.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:54:47'),
('11912', '11912', 2500.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:56:08'),
('11913', '11913', 522.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:56:53'),
('11914', '11914', 3350.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '08:52:23'),
('1192', '1192', 4327, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:50:37'),
('1193', '1193', 2999.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:50:57'),
('1194', '1194', 5496.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:51:20'),
('1195', '1195', 2550, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:51:35'),
('1196', '1196', 1877, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:51:50'),
('1197', '1197', 2366.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:52:39'),
('1198', '1198', 3268.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:53:08'),
('1199', '1199', 1434.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-05', '22:53:29'),
('1201', '1201', 5017.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:52:50'),
('12010', '1209', 1465, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:15:15'),
('12011', '12010', 418.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:15:50'),
('12012', '1201', 500.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:16:27'),
('12013', '12011', 1559.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:17:11'),
('12014', '12012', 2773, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:18:49'),
('12015', '12012', 258.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-09-19-12-120_18.png', '2020-11-26', '09:19:12'),
('12016', '12012', 225.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-09-23-32-120_18.png', '2020-11-26', '09:23:32'),
('12017', '12012', 217.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-09-26-07-120_18.png', '2020-11-26', '09:26:07'),
('12018', '12012', 95.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-09-27-52-120_18.png', '2020-11-26', '09:27:52'),
('12019', '12013', 246.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-09-59-18-120_12.png', '2020-11-26', '09:59:18'),
('1202', '1202', 2020.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:53:07'),
('12020', '12013', 481.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '10:05:42'),
('12021', '12013', 243, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-06-37-120_12.png', '2020-11-26', '10:06:37'),
('12022', '12013', 220.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-10-33-120_12.png', '2020-11-26', '10:10:33'),
('12023', '12013', 222.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-14-02-120_12.png', '2020-11-26', '10:14:02'),
('12024', '12013', 219, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-18-38-120_12.png', '2020-11-26', '10:18:38'),
('12025', '12013', 245, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-24-02-120_12.png', '2020-11-26', '10:24:02'),
('12026', '12013', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-27-46-120_12.png', '2020-11-26', '10:27:46'),
('12027', '12013', 186, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-28-29-120_12.png', '2020-11-26', '10:28:29'),
('12028', '12014', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-37-35-120_40.png', '2020-11-26', '10:37:35'),
('12029', '12014', 261.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-37-50-120_40.png', '2020-11-26', '10:37:50'),
('1203', '1203', 2537.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:53:27'),
('12030', '12014', 246.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-44-12-120_40.png', '2020-11-26', '10:44:12'),
('12031', '12014', 119.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-47-51-120_40.png', '2020-11-26', '10:47:51'),
('12032', '1209', 266.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-08-37-120_1.png', '2020-11-26', '11:08:37'),
('12033', '1209', 231, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-12-46-120_1.png', '2020-11-26', '11:12:46'),
('12034', '1209', 234.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-16-34-120_1.png', '2020-11-26', '11:16:34'),
('12035', '1209', 229.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-21-04-120_1.png', '2020-11-26', '11:21:04'),
('12036', '1209', 245, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-24-32-120_1.png', '2020-11-26', '11:24:32'),
('12037', '1209', 238.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-11-28-42-120_1.png', '2020-11-26', '11:28:42'),
('12038', '1209', 258.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-13-04-120_1.png', '2020-11-26', '12:13:04'),
('12039', '1209', 238.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-15-06-120_1.png', '2020-11-26', '12:15:06'),
('1204', '1204', 1763.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:53:44'),
('12040', '1209', 233.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-18-20-120_1.png', '2020-11-26', '12:18:20'),
('12041', '1209', 212, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-20-31-120_1.png', '2020-11-26', '12:20:31'),
('12042', '1209', 241, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-24-19-120_1.png', '2020-11-26', '12:24:19'),
('12043', '1209', 213.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-26-43-120_1.png', '2020-11-26', '12:26:43'),
('12044', '1209', 160, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-12-29-15-120_1.png', '2020-11-26', '12:29:15'),
('12045', '1209', 222.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-31-03-120_1.png', '2020-11-26', '13:31:03'),
('12046', '1209', 205.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-33-51-120_1.png', '2020-11-26', '13:33:51'),
('12047', '1209', 270.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-37-22-120_1.png', '2020-11-26', '13:37:22');
INSERT INTO `productor_fruta` (`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`, `hora_compra`) VALUES
('12048', '1209', 215.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-41-17-120_1.png', '2020-11-26', '13:41:17'),
('12049', '1209', 258.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-45-12-120_1.png', '2020-11-26', '13:45:12'),
('1205', '1205', 2094.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:54:29'),
('12050', '1209', 193.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-13-49-25-120_1.png', '2020-11-26', '13:49:25'),
('12051', '1209', 217, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-13-27-120_1.png', '2020-11-26', '14:13:27'),
('12052', '1209', 241.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-16-23-120_1.png', '2020-11-26', '14:16:23'),
('12053', '1209', 225.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-18-56-120_1.png', '2020-11-26', '14:18:56'),
('12054', '1209', 238, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-22-39-120_1.png', '2020-11-26', '14:22:39'),
('12055', '1209', 227, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-26-05-120_1.png', '2020-11-26', '14:26:05'),
('12056', '1209', 245.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '14:32:26'),
('12057', '1209', 199, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '14:34:04'),
('12058', '1209', 216, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-40-16-120_1.png', '2020-11-26', '14:40:16'),
('12059', '1209', 220.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-45-08-120_1.png', '2020-11-26', '14:45:08'),
('1206', '1206', 2534.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:54:46'),
('12060', '1209', 237.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-50-23-120_1.png', '2020-11-26', '14:50:23'),
('12061', '1209', 213.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '14:51:22'),
('12062', '1209', 228.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-54-17-120_1.png', '2020-11-26', '14:54:17'),
('12063', '1209', 220.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-56-11-120_1.png', '2020-11-26', '14:56:11'),
('12064', '1209', 246.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-14-58-39-120_1.png', '2020-11-26', '14:58:39'),
('12065', '1209', 214.2, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-01-04-120_1.png', '2020-11-26', '15:01:04'),
('12066', '1209', 219.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-03-36-120_1.png', '2020-11-26', '15:03:36'),
('12067', '1209', 145.4, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-06-30-120_1.png', '2020-11-26', '15:06:30'),
('12068', '1209', 231.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-10-24-120_1.png', '2020-11-26', '15:10:24'),
('12069', '1209', 211.6, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-13-39-120_1.png', '2020-11-26', '15:13:39'),
('1207', '1207', 6159.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:55:05'),
('12070', '1209', 219.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-18-20-120_1.png', '2020-11-26', '15:18:20'),
('12071', '1209', 190.8, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-15-21-35-120_1.png', '2020-11-26', '15:21:35'),
('12072', '1209', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-36-44-120_1.png', '2020-11-26', '10:36:44'),
('12073', '1209', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-37-22-120_1.png', '2020-11-26', '10:37:22'),
('12074', '1205', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-40-54-120_2.png', '2020-11-26', '10:40:54'),
('12075', '1205', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-42-53-120_2.png', '2020-11-26', '10:42:53'),
('12076', '1205', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-44-07-120_2.png', '2020-11-26', '10:44:07'),
('12077', '1205', 0, 'http://localhost/PLATANERATAB/vistas/assets/img/2020-11-26-10-46-48-120_2.png', '2020-11-26', '10:46:48'),
('12078', '1209', 601.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:19:01'),
('12079', '12015', 1054.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:21:13'),
('1208', '1208', 572.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:56:08'),
('12080', '12016', 3553.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-26', '09:24:56'),
('1209', '1209', 3068.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-25', '23:56:41'),
('1211', '1211', 10493.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:47:15'),
('12110', '12110', 1423, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:52:28'),
('12111', '12111', 436.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:52:50'),
('12112', '12112', 2046.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:53:11'),
('12113', '12113', 4930.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:53:30'),
('12114', '12114', 922.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:54:19'),
('12115', '12115', 123.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:54:35'),
('1212', '1212', 7749.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:50:03'),
('1213', '1213', 3379.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:50:18'),
('1214', '1214', 6529.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:50:34'),
('1215', '1215', 2985, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:50:48'),
('1216', '1216', 2208.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:51:04'),
('1217', '1217', 2513.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:51:17'),
('1218', '1218', 1527.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:51:48'),
('1219', '1219', 1826.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-11-30', '12:52:10'),
('771', '771', 12250.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:10:39'),
('7710', '7710', 1198.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:12:47'),
('7711', '7711', 191.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:12:58'),
('7712', '7712', 1672.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:13:11'),
('7713', '7713', 4063.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:13:23'),
('7714', '7714', 8811.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:13:37'),
('772', '772', 5364, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:11:01'),
('773', '773', 6428.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:11:12'),
('774', '774', 1338, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:11:26'),
('775', '775', 1613.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:11:41'),
('776', '776', 1565, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:11:55'),
('777', '777', 1243.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '13:12:06'),
('778', '778', 739.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:12:19'),
('779', '779', 711.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24', '13:12:34'),
('781', '781', 7026.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '15:38:13'),
('7810', '7810', 1760.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:06:20'),
('7811', '7811', 776.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:06:38'),
('7812', '7812', 1070.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:06:55'),
('7813', '7813', 2360, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:07:14'),
('7814', '7814', 2581.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:07:33'),
('7815', '7815', 2418, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:07:52'),
('7816', '7816', 869.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:08:10'),
('7817', '7817', 1789, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:08:24'),
('782', '782', 2446, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '15:42:24'),
('783', '783', 5187.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '15:43:31'),
('784', '784', 1875.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '15:43:31'),
('785', '785', 2642.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:04:51'),
('786', '786', 9807.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:05:13'),
('787', '787', 2646, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:05:30'),
('788', '788', 1674.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:05:48'),
('789', '789', 586.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '16:06:03'),
('791', '791', 10120, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7910', '7910', 1790.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7911', '7911', 446.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7912', '7912', 686.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7913', '7913', 760.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7914', '7914', 182.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7915', '7915', 648.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7916', '7916', 1505.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7917', '7917', 714.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7918', '7918', 1129.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7919', '7919', 1081, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('792', '792', 3454.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7920', '7920', 269.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7921', '7921', 2554.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('7922', '7922', 1217.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('793', '793', 867.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('794', '794', 4882.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('795', '795', 3176.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('796', '796', 2236.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('797', '797', 4550, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('798', '798', 1078.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('799', '799', 2582.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-25', '00:00:00'),
('801', '801', 10059.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('8010', '8010', 1351.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('8011', '8011', 988.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('8012', '8012', 5568.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('802', '802', 4740.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('803', '803', 10281.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('804', '804', 706.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('805', '805', 2314.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('806', '806', 1922.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('807', '807', 1440.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('808', '808', 2021, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('809', '809', 1353, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-28', '00:00:00'),
('811', '811', 8199.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8110', '8110', 846.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8111', '8111', 1977.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8112', '8112', 1633, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8113', '8113', 484.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8114', '8114', 403.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('8115', '8115', 1700, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('812', '812', 2062, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('813', '813', 8907, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('814', '814', 1279.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('815', '815', 2326, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('816', '816', 993.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('817', '817', 2504, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('818', '818', 3196, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('819', '819', 2972.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-29', '00:00:00'),
('821', '821', 1097.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8210', '8210', 2084.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8211', '8211', 1101.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8212', '8212', 1114.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8213', '8213', 846.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8214', '8214', 1341, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8215', '8215', 906.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8216', '8216', 758.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8217', '8217', 1900, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8218', '8218', 2533.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('8219', '8219', 2507.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('822', '822', 10022.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('823', '823', 6847.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('824', '824', 1251.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('825', '825', 5509.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('826', '826', 1756.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('827', '827', 2732.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('828', '828', 2923.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('829', '829', 1448.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-30', '00:00:00'),
('831', '831', 1188.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8310', '8310', 743.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8311', '8311', 3024, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8312', '8312', 2649.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8313', '8313', 1846.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8314', '8314', 8214, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8315', '8315', 3964.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8316', '8316', 5281.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('8317', '8317', 5690.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('832', '832', 2270.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('833', '833', 209.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('834', '834', 4061, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('835', '835', 2178.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('836', '836', 795.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('837', '837', 3252.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('838', '838', 1539.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('839', '839', 1396.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-31', '00:00:00'),
('841', '841', 9628.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8410', '8410', 2337.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8411', '8411', 2554.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8412', '8412', 3729, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8413', '8413', 221.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8414', '8414', 2331.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8415', '8415', 2465.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('8416', '8416', 2483.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('842', '842', 1455.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('843', '843', 7816.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('844', '844', 2495.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('845', '845', 4188.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('846', '846', 2291, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('847', '847', 1438.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('848', '848', 1523, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('849', '849', 2290, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-01', '00:00:00'),
('851', '851', 1536.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('8510', '8510', 837.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('8511', '8511', 507.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('8512', '8512', 1130, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('8513', '8513', 675.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('8514', '8514', 975.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('852', '852', 11291.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('853', '853', 3919.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('854', '854', 4004.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('855', '855', 8004.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('856', '856', 2398.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('857', '857', 3724, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('858', '858', 2414.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('859', '859', 1028, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-02', '00:00:00'),
('861', '861', 1372.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8610', '8610', 1160.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8611', '8611', 2373.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8612', '8612', 276.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8613', '8613', 695.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8614', '8614', 1529, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8615', '8615', 1078.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('8616', '8616', 425.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('862', '862', 12244.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('863', '863', 3181.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('864', '864', 3906, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('865', '865', 7402, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('866', '866', 1985, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('867', '867', 3758.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('868', '868', 2692.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('869', '869', 2321.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-03', '00:00:00'),
('871', '871', 1335.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('8710', '8710', 1150.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('8711', '8711', 426.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('8712', '8712', 1489.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('8713', '8713', 586.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('8714', '8714', 1407.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('872', '872', 12955.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('873', '873', 3064.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('874', '874', 3151.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('875', '875', 6859.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('876', '876', 2043, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('877', '877', 4047, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('878', '878', 3156.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('879', '879', 2324.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-04', '00:00:00'),
('881', '881', 12962, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8810', '8810', 1073.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8811', '8811', 1074.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8812', '8812', 140.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8813', '8813', 558.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8814', '8814', 1205.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8815', '8815', 948.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('8816', '8816', 2041.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('882', '882', 3992.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('883', '883', 4165.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('884', '884', 7114.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('885', '885', 2891.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('886', '886', 3796.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('887', '887', 3544.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('888', '888', 1357.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('889', '889', 2384.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-05', '00:00:00'),
('891', '891', 1561.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('8910', '8910', 1278, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('8911', '8911', 1495.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('8912', '8912', 801.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('8913', '8913', 1391.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('8914', '8914', 2543.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('892', '892', 8881.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('893', '893', 4866.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('894', '894', 4271.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('895', '895', 7965.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('896', '896', 3061.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('897', '897', 3785.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('898', '898', 2962.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('899', '899', 1975.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-06', '00:00:00'),
('901', '901', 10149.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('9010', '9010', 1521.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('9011', '9011', 453, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('9012', '9012', 518.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('9013', '9013', 1686.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('9014', '9014', 2525.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('902', '902', 4315, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('903', '903', 4172.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('904', '904', 9341, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('905', '905', 2536, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('906', '906', 3815.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('907', '907', 3297, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('908', '908', 2121.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('909', '909', 1343.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-07', '00:00:00'),
('911', '911', 3172, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('9110', '9110', 990.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('9111', '9111', 509, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('9112', '9112', 985.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('9113', '9113', 2531, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('912', '912', 11000, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('913', '913', 3950, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('914', '914', 4413.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('915', '915', 8550, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('916', '916', 3357, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('917', '917', 3525.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('918', '918', 3943, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('919', '919', 1853.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-08', '00:00:00'),
('921', '921', 13173, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:10:44'),
('9210', '9210', 678.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:13:38'),
('9211', '9211', 1215.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:14:11'),
('9212', '9212', 1050.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:14:37'),
('9213', '9213', 1292, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:14:59'),
('9214', '9214', 2748.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:15:14'),
('922', '922', 4139.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:11:04'),
('923', '923', 4008.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:11:19'),
('924', '924', 8612.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:11:34'),
('925', '925', 3052.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:11:49'),
('926', '926', 3219, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:12:24'),
('927', '927', 3070, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:12:40'),
('928', '928', 1404, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:12:58'),
('929', '929', 1115.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-09', '20:13:16'),
('931', '931', 10874.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:46:56'),
('9310', '9310', 2839.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:50:55'),
('9311', '9311', 507.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:51:10'),
('9312', '9312', 1022.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:51:55'),
('9313', '9313', 2591.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:52:25'),
('932', '932', 4009, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:47:11'),
('933', '933', 3238.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:47:36'),
('934', '934', 7254.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:47:48'),
('935', '935', 2994.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:48:22'),
('936', '936', 3063.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:48:50'),
('937', '937', 1568.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:49:17'),
('938', '938', 1003.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:49:34'),
('939', '939', 359.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-10', '20:50:31'),
('941', '941', 9905.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:54:06'),
('9410', '9410', 808.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:58:48'),
('9411', '9411', 1363.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:59:08'),
('9412', '9412', 2853.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:59:25'),
('9413', '9413', 2253.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '22:00:47'),
('942', '942', 3496.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:54:19'),
('943', '943', 5012.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:54:43'),
('944', '944', 8330.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:55:08'),
('945', '945', 3003, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:55:21'),
('946', '946', 5013.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:55:34'),
('947', '947', 1464.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:55:51'),
('948', '948', 2420.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:57:09'),
('949', '949', 1548, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-11', '21:58:21'),
('951', '951', 5603.19, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:23:56'),
('9510', '9510', 2019.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:26:54'),
('9511', '9511', 482.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:27:10'),
('9512', '9512', 1023.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:27:38'),
('9513', '9513', 1645.7, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:27:53'),
('9514', '9514', 3953.5, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:28:08'),
('9515', '9515', 1451.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:28:23'),
('952', '952', 4963, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:24:17'),
('953', '953', 5012, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:24:43'),
('954', '954', 7435.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:24:59'),
('955', '955', 4249.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:25:12'),
('956', '956', 3622.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:25:33'),
('957', '957', 3017.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:25:59'),
('958', '958', 1648.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:26:17'),
('959', '959', 1370.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-12', '22:26:32'),
('961', '961', 10016.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:42:29'),
('9610', '9610', 1187.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:45:19'),
('9611', '9611', 3042, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:45:42'),
('9612', '9612', 1532.9, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:46:01'),
('962', '962', 4245.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:42:42'),
('963', '963', 4428.3, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:42:56'),
('964', '964', 7634.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:43:09'),
('965', '965', 3506.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:43:22'),
('966', '966', 4513.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:44:05'),
('967', '967', 2242, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:44:24'),
('968', '968', 2308.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:44:47'),
('969', '969', 839.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-13', '10:45:03'),
('971', '971', 9580, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:00:55'),
('9710', '9710', 1886.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:03:34'),
('9711', '9711', 129, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:03:58'),
('9712', '9712', 784.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:04:18'),
('9713', '9713', 1525.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:04:32'),
('9714', '9714', 3079.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:04:58'),
('9715', '9715', 1472, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:05:27'),
('972', '972', 3556.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:01:10'),
('973', '973', 3883, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:01:22'),
('974', '974', 8014.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:01:34'),
('975', '975', 3028.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:01:44'),
('976', '976', 4048.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:01:59'),
('977', '977', 2647.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:02:53'),
('978', '978', 2014.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:03:07'),
('979', '979', 1036.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-14', '11:03:19'),
('981', '981', 7068.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:21:18'),
('9810', '9810', 210.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:23:14'),
('9811', '9811', 862.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:25:52'),
('9812', '9812', 3898.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:26:10'),
('9813', '9813', 459.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:32:26'),
('982', '982', 797, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:21:30'),
('983', '983', 3198, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:21:43'),
('984', '984', 5613, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:21:55'),
('985', '985', 4598.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:22:07'),
('986', '986', 3455.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:22:18'),
('987', '987', 2171, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:22:29'),
('988', '988', 2724.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:22:48'),
('989', '989', 1834.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-15', '11:23:01'),
('991', '991', 5785.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:03:50'),
('9910', '9910', 2170, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:08:43'),
('9911', '9911', 3291.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:08:57'),
('9912', '9912', 1560.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:12:47'),
('9913', '9913', 1801.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:19:40'),
('9914', '9914', 952, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:19:55'),
('9915', '9915', 1454.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:20:07'),
('9916', '9916', 878.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:20:29'),
('9917', '9917', 991, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:20:52'),
('9918', '9918', 547.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:21:24'),
('9919', '9919', 1379, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:21:51'),
('992', '992', 5566.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:04:46'),
('993', '993', 2567.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:04:59'),
('994', '994', 5908, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:05:15'),
('995', '995', 4831, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:06:47'),
('996', '996', 1788.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:07:02'),
('997', '997', 974, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:07:21'),
('998', '998', 1977, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:07:40'),
('999', '999', 1163.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-08-16', '12:08:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
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
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `user`, `password`, `nombre`, `genero`, `tipo`, `estado`) VALUES
(1, 'admin', 'eGVlUnJPNng4d09uZ0w3aFlXODFpUT09', 'Administrador Admin', 'Masculino', 1, 'ALTA'),
(2, 'root', 'eU9KT0h4ek44NDhLcUxqc1ZZZ0JxQT09', 'Capturista Root', 'Masculino', 2, 'ALTA'),
(3, 'nancy', 'd2E2eG9WcXZ4VGFQSEl1MHpSaC8vdz09', 'nancy cortaza', 'Femenino', 2, 'ALTA'),
(10000, 'adan', 'STd2NSs0ZHRPOWJ6eDYzYmhoMjM5UT09', 'adan escobar', 'Masculino', 1, 'ALTA');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bolsas`
--
ALTER TABLE `bolsas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_cuenta` (`id_cuenta`);

--
-- Indices de la tabla `bolsas_bolsero`
--
ALTER TABLE `bolsas_bolsero`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Bolsas_Bolsero_fk0` (`id_bolsero`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `bolsas_diarias`
--
ALTER TABLE `bolsas_diarias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `bolsas_pelador`
--
ALTER TABLE `bolsas_pelador`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Bolsas_Pelador_fk0` (`id_pelador`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `bolsas_toston`
--
ALTER TABLE `bolsas_toston`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_planilla` (`id_planilla`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `bolseros`
--
ALTER TABLE `bolseros`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `bolsero_extra`
--
ALTER TABLE `bolsero_extra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_embarque` (`id_embarque`);

--
-- Indices de la tabla `cuenta_bolsas`
--
ALTER TABLE `cuenta_bolsas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idemb` (`idemb`);

--
-- Indices de la tabla `cuenta_dolares`
--
ALTER TABLE `cuenta_dolares`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_emb` (`id_emb`);

--
-- Indices de la tabla `cuenta_pesos`
--
ALTER TABLE `cuenta_pesos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_emb` (`id_emb`);

--
-- Indices de la tabla `dolares`
--
ALTER TABLE `dolares`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_cuentaD` (`id_cuentaD`);

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
  ADD KEY `Extra_fk1` (`id_bolsas_bolsero`);

--
-- Indices de la tabla `fruta`
--
ALTER TABLE `fruta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Fruta_fk0` (`id_productores`),
  ADD KEY `Fruta_fk1` (`id_embarque`);

--
-- Indices de la tabla `gastos`
--
ALTER TABLE `gastos`
  ADD PRIMARY KEY (`id_gasto`);

--
-- Indices de la tabla `gastos_embarque`
--
ALTER TABLE `gastos_embarque`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_embarque` (`id_embarque`),
  ADD KEY `id_gasto` (`id_gasto`);

--
-- Indices de la tabla `peladores`
--
ALTER TABLE `peladores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pelador_extra`
--
ALTER TABLE `pelador_extra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_bolsaspelador` (`id_bolsaspelador`);

--
-- Indices de la tabla `pesos`
--
ALTER TABLE `pesos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_cuenta` (`id_cuenta`);

--
-- Indices de la tabla `planilla_toston`
--
ALTER TABLE `planilla_toston`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `precio_compra`
--
ALTER TABLE `precio_compra`
  ADD PRIMARY KEY (`id_precio`);

--
-- Indices de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_fruta` (`id_fruta`);

--
-- Indices de la tabla `productores`
--
ALTER TABLE `productores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `productor_fruta`
--
ALTER TABLE `productor_fruta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_fruta` (`id_fruta`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `bolseros`
--
ALTER TABLE `bolseros`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `embarque`
--
ALTER TABLE `embarque`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT de la tabla `gastos`
--
ALTER TABLE `gastos`
  MODIFY `id_gasto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `peladores`
--
ALTER TABLE `peladores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT de la tabla `planilla_toston`
--
ALTER TABLE `planilla_toston`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `precio_compra`
--
ALTER TABLE `precio_compra`
  MODIFY `id_precio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `productores`
--
ALTER TABLE `productores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10001;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bolsas`
--
ALTER TABLE `bolsas`
  ADD CONSTRAINT `bolsas_ibfk_1` FOREIGN KEY (`id_cuenta`) REFERENCES `cuenta_bolsas` (`id`);

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
-- Filtros para la tabla `bolsas_toston`
--
ALTER TABLE `bolsas_toston`
  ADD CONSTRAINT `bolsas_toston_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`),
  ADD CONSTRAINT `bolsas_toston_ibfk_2` FOREIGN KEY (`id_planilla`) REFERENCES `planilla_toston` (`id`);

--
-- Filtros para la tabla `bolsero_extra`
--
ALTER TABLE `bolsero_extra`
  ADD CONSTRAINT `bolsero_extra_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`);

--
-- Filtros para la tabla `dolares`
--
ALTER TABLE `dolares`
  ADD CONSTRAINT `dolares_ibfk_1` FOREIGN KEY (`id_cuentaD`) REFERENCES `cuenta_dolares` (`id`);

--
-- Filtros para la tabla `extra`
--
ALTER TABLE `extra`
  ADD CONSTRAINT `extra_ibfk_1` FOREIGN KEY (`id_bolsas_bolsero`) REFERENCES `bolsas_bolsero` (`id`);

--
-- Filtros para la tabla `fruta`
--
ALTER TABLE `fruta`
  ADD CONSTRAINT `fruta_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`),
  ADD CONSTRAINT `fruta_ibfk_2` FOREIGN KEY (`id_productores`) REFERENCES `productores` (`id`);

--
-- Filtros para la tabla `gastos_embarque`
--
ALTER TABLE `gastos_embarque`
  ADD CONSTRAINT `gastos_embarque_ibfk_1` FOREIGN KEY (`id_embarque`) REFERENCES `embarque` (`id`),
  ADD CONSTRAINT `gastos_embarque_ibfk_2` FOREIGN KEY (`id_gasto`) REFERENCES `gastos` (`id_gasto`);

--
-- Filtros para la tabla `pelador_extra`
--
ALTER TABLE `pelador_extra`
  ADD CONSTRAINT `pelador_extra_ibfk_1` FOREIGN KEY (`id_bolsaspelador`) REFERENCES `bolsas_pelador` (`id`);

--
-- Filtros para la tabla `pesos`
--
ALTER TABLE `pesos`
  ADD CONSTRAINT `pesos_ibfk_1` FOREIGN KEY (`id_cuenta`) REFERENCES `cuenta_pesos` (`id`);

--
-- Filtros para la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD CONSTRAINT `prestamos_ibfk_1` FOREIGN KEY (`id_fruta`) REFERENCES `fruta` (`id`);

--
-- Filtros para la tabla `productor_fruta`
--
ALTER TABLE `productor_fruta`
  ADD CONSTRAINT `productor_fruta_ibfk_1` FOREIGN KEY (`id_fruta`) REFERENCES `fruta` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
