-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-08-2020 a las 21:32:45
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

DELIMITER $$
--
-- Procedimientos
--
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarBolsero` (IN `Id_b` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_b` INT)  NO SQL
UPDATE `bolseros` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM, `Tipo`=Tipo_b WHERE id = Id_b$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPelador` (IN `id_p` INT, IN `Nombre_p` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tipo_p` INT)  NO SQL
UPDATE peladores SET nombre=Nombre_p, Ap_p= ApP, Ap_M= ApM, Tipo= Tipo_p where id=id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarPro` (IN `Id_pro` INT, IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
UPDATE `productores` SET `nombre`=Nombre, `Ap_p`=ApP, `Ap_m`=ApM
WHERE id = Id_pro$$

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
            INSERT INTO `prestamos`(`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@buscFruta, @regSaFun, @regSaFer, @regSaPre, @regPFun, @regPFer, @regPPag, @cantFun, @cantFer, @cantPag, (@regSaFun-@cantFun), (@regSaFer-@cantFer), (@regSaPre-@cantPag), @regAbFun, @regAbFer, @regAbPag);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `addBolsas` (IN `embarque` INT, IN `concep` VARCHAR(50), IN `egre` FLOAT)  BEGIN
	SET @saldoBolsas=(SELECT saldo FROM cuenta_bolsas WHERE idemb=embarque);
    SET @idCB=(SELECT id FROM cuenta_bolsas WHERE idemb=embarque);
    SET @idB=CONCAT(embarque, (SELECT COUNT(bolsas.id) FROM bolsas, cuenta_bolsas WHERE cuenta_bolsas.id=bolsas.id_cuenta AND cuenta_bolsas.idemb=embarque)+1);
    
    UPDATE `cuenta_bolsas` SET `egreso`=`egreso`+egre,`saldo`=(`saldo`-egre) WHERE id=@idCB;
    
    INSERT INTO `bolsas`(`id`, `id_cuenta`, `concepto`, `ingreso`, `egreso`, `saldo`, `activo`) VALUES (@idB, @idCB, concep, 0, egre, (@saldoBolsas-egre), 1);
    
    -- Actualizar los saldos del embarque siguiente si la cuenta del embarque actual esta cerrada
    CALL actSaldosAnteriores(3, embarque, @idCB, 0, egre);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addBolsero` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `bolseros`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) VALUES (Nom, ApP, ApM, Tip)$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPelador` (IN `Nom` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255), IN `Tip` INT)  NO SQL
INSERT INTO `peladores`(`nombre`, `Ap_p`, `Ap_m`, `Tipo`) 
VALUES (Nom, ApP, ApM, Tip)$$

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
    -- Buscar el ultimo registro en pretamos para obtener sus saldos y no de pagos
        SET @idPrestamo=(SELECT prestamos.id FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        
        IF @idPrestamo>0 THEN
            SET @saldoFun=(SELECT saldo_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
            SET @saldoFer=(SELECT saldo_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
            SET @saldoPre=(SELECT saldo_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosFun=(SELECT no_pagos_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosFer=(SELECT no_pagos_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosPre=(SELECT no_pagos_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
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
            -- Actualizar el registro de la tabla prestamos
        	UPDATE prestamos SET `fungicida`=`fungicida`+@cat_fun, `fertilizante`=`fertilizante`+@cat_fer, `prestamo`=`prestamo`+@cat_pag, `no_pagos_fungicida`=@noPagfun, `no_pagos_fertilizante`=@noPagfer, `no_pagos_prestamo`=@noPagpag, `saldo_fungicida`=`saldo_fungicida`+@cat_fun, `saldo_fertilizante`=`saldo_fertilizante`+@cat_fer, `saldo_prestamo`=`saldo_prestamo`+@cat_pag, `abono_cantidad_fungicida`=(`fungicida`)/@noPagfun, `abono_cantidad_fertilizante`=(`fertilizante`)/@noPagfer, `abono_cantidad_prestamo`=(`prestamo`)/@noPagpag WHERE `id`=@idPrestamo;
		ELSE
        	-- Obtener el numero de pagos segun el tipo de prestamo
        	IF tipo=1 THEN
                SET @noPagfun=noPagos;
            ELSEIF tipo=2 THEN
                SET @noPagfer=noPagos;
            ELSE
                SET @noPagpag=noPagos;
            END IF;
            SET @idNuevo=CONCAT(embarque, (SELECT COUNT(prestamos.id) FROM prestamos, fruta WHERE fruta.id_embarque=embarque AND fruta.id=prestamos.id_fruta)+1);
            -- INSERTAR en la tabla Prestamos
            INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @buscPrestamo, @cat_fun, @cat_fer, @cat_pag, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0, @cat_fun, @cat_fer, @cat_pag, (@cat_fun/noPagos), (@cat_fer/noPagos), (@cat_pag/noPagos) );
        END IF;
    ELSE
    -- Generar id para la tabla fruta
    	SET @idFruta=CONCAT(embarque, (SELECT COUNT(id) FROM fruta WHERE id_embarque=embarque)+1);
        -- Insertar en la tabla fruta
    	INSERT INTO `fruta`(`id`,`id_productores`, `peso_kg`, `pago`, `saldo_abono`, `id_embarque`) VALUES (@idFruta, productor, 0, 0, 0, embarque);
        -- Buscar el ultimo registro en pretamos para obtener sus saldos y no de pagos
        	SET @idPrestamo=(SELECT prestamos.id FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
            -- Si existe un registro...
            IF @isPrestamo>0 THEN
            SET @saldoFun=(SELECT saldo_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
            SET @saldoFer=(SELECT saldo_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
            SET @saldoPre=(SELECT saldo_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosFun=(SELECT no_pagos_fungicida FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosFer=(SELECT no_pagos_fertilizante FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
        	SET @pagosPre=(SELECT no_pagos_prestamo FROM `prestamos`, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id=@buscPrestamo);
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
		ELSE
        	-- Obtener el numero de pagos segun el tipo de prestamo
        	IF tipo=1 THEN
                SET @noPagfun=noPagos;
            ELSEIF tipo=2 THEN
                SET @noPagfer=noPagos;
            ELSE
                SET @noPagpag=noPagos;
            END IF;
            
         END IF;
            SET @idNuevo=CONCAT(embarque, (SELECT COUNT(prestamos.id) FROM prestamos, fruta WHERE fruta.id_embarque=embarque AND fruta.id=prestamos.id_fruta)+1);
            -- INSERTAR en la tabla Prestamos
            INSERT INTO `prestamos`(`id`,`id_fruta`, `fungicida`, `fertilizante`, `prestamo`, `no_pagos_fungicida`, `no_pagos_fertilizante`, `no_pagos_prestamo`, `abono_fungicida`, `abono_fertilizante`, `abono_prestamo`, `saldo_fungicida`, `saldo_fertilizante`, `saldo_prestamo`, `abono_cantidad_fungicida`, `abono_cantidad_fertilizante`, `abono_cantidad_prestamo`) VALUES (@idNuevo, @idFruta, @cat_fun, @cat_fer, @cat_pag, @noPagfun, @noPagfer, @noPagpag, 0, 0, 0, @cat_fun, @cat_fer, @cat_pag, (@cat_fun/noPagos), (@cat_fer/noPagos), (@cat_pag/noPagos) );
            
    END IF;
    -- Actualizar o registrar gastos
    /*
    	CALL regGastoEmbarque(embarque, @tg,cantidad);
    */
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addProductores` (IN `Nombre` VARCHAR(255), IN `ApP` VARCHAR(255), IN `ApM` VARCHAR(255))  NO SQL
INSERT INTO `productores`(`nombre`, `Ap_p`, `Ap_m`)
VALUES (Nombre, ApP, ApM)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_peso` (IN `id_e` INT, IN `egre` FLOAT, IN `con` VARCHAR(100))  NO SQL
    COMMENT 'Se utilizará al insertar un nuevo egreso (Comisión Banco)'
BEGIN
 set @saldo=(SELECT saldo from pesos INNER join cuenta_pesos ON pesos.id_cuenta=cuenta_pesos.id
where cuenta_pesos.id_emb=id_e ORDER BY pesos.saldo DESC LIMIT 1);

  set @cuenta=(select id_cuenta from pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id
where cuenta_pesos.id_emb=id_e ORDER BY pesos.id_cuenta desc LIMIT 1);

INSERT into pesos(id_cuenta, concepto, egreso, saldo) VALUES (@cuenta, con, egre, @saldo-egre);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarCuentaD` (IN `id_e` INT(20), IN `concepto` VARCHAR(255), IN `ingreso` FLOAT, IN `egreso` FLOAT, IN `saldo` FLOAT)  NO SQL
begin 
	set @exist=(SELECT COUNT(cuenta_dolares.id_emb) from cuenta_dolares where id_emb=id_e );
    
    IF @exist=0 then INSERT into cuenta_dolares( id_emb ,total_ingreso, total_egreso,  total_saldo) values (id_e, ingreso, egreso, 5645) ;
    
   
    set @id=(SELECT id from cuenta_dolares where id_emb=id_e);
    INSERT into dolares(id_cuentaD, concepto, ingreso, egreso, saldo) values (@id, concepto, ingreso, egreso, saldo);
    end if;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_gastos` (IN `id_emb` INT(20), IN `pes` INT(11), IN `pag` INT(11), IN `id_g` INT(20))  NO SQL
BEGIN
 set @count= (SELECT COUNT(id) from gastos_embarque where id_embarque = id_emb and id_gasto=1);
    
    if( @count=0)
        then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 				`cantidad`) VALUES (id_emb, 1, (pes * pag));
     ELSE UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + (pes * pag)) 			WHERE `id`=id_g;

 end IF;
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cerraCuenta` (IN `embarque` INT)  BEGIN
	SET @saldoDolar=(SELECT total_saldo from cuenta_dolares WHERE id_emb=embarque);
    SET @saldoPesos=(SELECT total_saldo from cuenta_pesos WHERE id_emb=embarque);
    SET @saldoBolsas=(SELECT saldo from cuenta_bolsas WHERE idemb=embarque);
    -- Dolares
    SET @idCD=CONCAT(embarque, (SELECT COUNT(id) FROM cuenta_dolares WHERE id_emb=embarque)+1);
    SET @idD=CONCAT(embarque, (SELECT COUNT(dolares.id) FROM dolares, cuenta_dolares WHERE cuenta_dolares.id_emb=embarque AND cuenta_dolares.id=dolares.id_cuentaD)+1);
    INSERT INTO cuenta_dolares (`id`, id_emb, total_saldo) VALUES (@idCD, (embarque+1), @saldoDolar);
    INSERT INTO `dolares`(`id`, `id_cuentaD`, `concepto`, `saldo`) VALUES (@idD, @idCD,'SALDO ANTERIOR', @saldoDolar);
    -- Bolsas
    SET @idCB=CONCAT(embarque, (SELECT COUNT(id) FROM cuenta_bolsas WHERE idemb=embarque)+1);
    SET @idB=CONCAT(embarque, (SELECT COUNT(bolsas.id) FROM bolsas, cuenta_bolsas WHERE cuenta_bolsas.idemb=embarque AND cuenta_bolsas.id=bolsas.id_cuenta)+1);
    INSERT INTO cuenta_bolsas (id, idemb, saldo) VALUES (@idCB, (embarque+1), @saldoBolsas);
    INSERT INTO `bolsas`(`id`, `id_cuenta`, `concepto`, `saldo`) VALUES (@idB, @idCB, 'SALDO ANTERIOR', @saldoBolsas);
    -- Pesos
    SET @idCP=(SELECT cuenta_pesos.id FROM `cuenta_pesos` WHERE cuenta_pesos.id_emb=(embarque+1));
    UPDATE `pesos` SET `saldo`=@saldoPesos WHERE id_cuenta=@idCP;
    UPDATE cuenta_pesos SET total_saldo=total_saldo+@saldoPesos WHERE id=@idCP;
    -- Actualizar Embarque
    UPDATE embarque SET cuentas=1 WHERE id=embarque;
END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteBolsero` (IN `id_b` INT)  NO SQL
DELETE from bolseros where id= id_b$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePelador` (IN `Id_p` INT)  NO SQL
DELETE FROM `peladores` WHERE id = Id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProd` (IN `Id_p` INT)  NO SQL
DELETE from productores WHERE id = Id_p$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `elimGastoEmbarque` (IN `idg` INT, IN `cant` FLOAT, IN `embarque` INT)  BEGIN
    
	-- DELETE FROM gastos_embarque WHERE id=idg;
    UPDATE gastos_embarque SET cantidad=0 WHERE id=idg; 
    
    UPDATE `embarque` SET `total_gastos`=`total_gastos`-cant WHERE id=embarque;
    
    CALL actPesosCuenta(embarque, (-1*cant) );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modGastoEmbarque` (IN `idG` INT, IN `embarque` INT, IN `cant` FLOAT, IN `cant_new` FLOAT)  BEGIN
	
    UPDATE gastos_embarque SET cantidad=cant_new WHERE id=idG;
    
    SET @cantiMod=cant_new-cant;
    
    UPDATE embarque SET total_gastos=total_gastos+@cantiMod WHERE id=embarque;
    
    CALL actPesosCuenta(embarque, @cantiMod);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `opt_gastos` (IN `op` INT(10), IN `tipo` INT(10), IN `id_g` INT(20), IN `id_emb` INT(20), IN `peso` INT(10), IN `pago` INT(10))  NO SQL
CASE op 
    when 1 then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 					`cantidad`) VALUES (id_emb, tipo, (peso * pago)) ;
    when 2 then UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + 					(peso * pago)) WHERE `id`=id_g;
    when 3 then INSERT INTO `gastos_embarque`(`id_embarque`, `id_gasto`, 					`cantidad`) VALUES (id_emb, tipo, pago); 
    when 4 then  UPDATE `gastos_embarque` SET `cantidad`=(`cantidad` + 					pago) WHERE `id`=id_g;
  
    
    end case$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regBOLExtra` (IN `opc` INT, IN `embarque` INT, IN `nom` VARCHAR(50), IN `ap` VARCHAR(50), IN `anios` INT, IN `tel` VARCHAR(14), IN `dir` VARCHAR(100), IN `cuen` VARCHAR(50), IN `trab` VARCHAR(50), IN `pag` FLOAT, IN `fec` DATE, IN `id_dat` INT)  BEGIN
	# Si opc es 1 entonces registramos al trabajador
    # Si opc es >3 (ya que enviamos el ID) entonces modificamos los datos del trabajador
    # Si opc es 3 entonces *"Eliminamos"* los datos del trabajador
	IF opc=1 THEN
    	SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM bolsero_extra WHERE id_embarque=embarque)+1);
    	INSERT INTO `bolsero_extra`(`id`, `nombre`, `apellidos`, `edad`, `telefono`, `direccion`, `cuenta`, `actividad`, `pago`, `id_embarque`, `fecha`) VALUES (@idNew, nom, ap, anios, tel, dir, cuen, trab, pag, embarque, fec);
        
        -- Actualizar Gastos (Tipo Bolsero ~3~) de embarque, gastos_embarque y cuenta pesos
        SET @buscGastPT=(SELECT id FROM gastos_embarque WHERE id_embarque=embarque AND id_gasto=3);
        UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+@cantidadNew WHERE id=embarque;
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
        UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
        IF @buscGastPT>0 THEN
        	UPDATE `gastos_embarque` SET `cantidad`=(`cantidad`-pag) WHERE `id`=@buscGastPT;
        ELSE
        	SET @idGast=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
            INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`) VALUES (@idGast, embarque, 3, pg);
		END IF;
        CALL actPesosCuenta(embarque, (pag*(-1)));
        
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regBolsas` (IN `embarque` INT, IN `pelador` INT, IN `productor` INT, IN `bolsero` INT, IN `fecha` DATE, IN `hora` VARCHAR(30) CHARSET utf8mb4, IN `num_bol` INT(5), IN `pagoPel` FLOAT)  BEGIN
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
    UPDATE `embarque` SET `cant_bolsas_embarque`= (`cant_bolsas_embarque`+1), `total_gastos`=`total_gastos`+pagoPel WHERE id=embarque;
    -- INSERTAR en la tabla bolsas diarias la bolsas agregada
    SET @idBolDia=CONCAT(embarque, (SELECT COUNT(`id`) FROM `bolsas_diarias` WHERE `id_embarque`=embarque)+1);
    INSERT INTO `bolsas_diarias`(`id`,`numero`, `id_embarque`, `hora`, `fecha`, `pelador`, `id_bolsero`, `id_productor`) VALUES (@idBolDia, (num_bol+1), embarque, hora, fecha, pelador, bolsero, productor);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `regFruta` (IN `productor` INT(4), IN `embarque` INT(11), IN `peso` FLOAT, IN `fecha` DATE, IN `img` VARCHAR(255), IN `pago_f` FLOAT)  BEGIN
	-- Buscar si existe registro de Fruta para el productor
	SET @buscarFruta=(SELECT id FROM fruta WHERE id_productores=productor AND id_embarque=embarque);
    
    IF @buscarFruta>0 THEN
        -- Actualizar al productor en la tabla fruta
        UPDATE `fruta` SET `peso_kg`=`peso_kg`+peso,`pago`=pago_f,`saldo_abono`=`peso_kg`*`pago` WHERE `id`=@buscarFruta;
        -- Generar Id para productor_fruta
        SET @idNewPF=CONCAT(embarque, (SELECT COUNT(productor_fruta.id) FROM productor_fruta, fruta WHERE productor_fruta.id_fruta=fruta.id AND fruta.id_embarque=embarque)+1);
        -- Registramos en la tabla productor_fruta
        INSERT INTO `productor_fruta`(`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`) VALUES (@idNewPF, @buscarFruta, peso, img, fecha);
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
        INSERT INTO `productor_fruta`(`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`) VALUES (@idNewPF, @idNuevo, peso, img, fecha); 
        -- Registramos el gasto y actualizar cuenta
    	CALL regGastoEmbarque(embarque, 1, (peso*pago_f), 0);
        
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regGastoEmb` (IN `embarque` INT, IN `tg` INT, IN `cant` FLOAT, IN `concepto` VARCHAR(50))  BEGIN
	SET @idNew=CONCAT(embarque, (SELECT COUNT(id) FROM gastos_embarque WHERE id_embarque=embarque)+1);
    INSERT INTO `gastos_embarque`(`id`, `id_embarque`, `id_gasto`, `cantidad`, `extra`) VALUES (@idNew, embarque, tg, cant, concepto);
    UPDATE embarque SET total_gastos=total_gastos+cant WHERE id=embarque;
    CALL actPesosCuenta(embarque, cant);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regGastoEmbarque` (IN `embarque` INT, IN `tipo` INT, IN `cant` FLOAT, IN `kg` FLOAT)  BEGIN
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
    
    UPDATE embarque SET total_gastos=total_gastos+cant WHERE id=embarque;
    CALL actPesosCuenta(embarque, cant);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regPeladorExtra` (IN `op` INT, IN `idP` INT, IN `idBP` VARCHAR(25), IN `trab` INT, IN `con` VARCHAR(50), IN `pag` FLOAT, IN `fech` DATE, IN `emb` INT, IN `id_extra` VARCHAR(25))  BEGIN
#op 1 = insertar trabajo extra para el pelador
#op 2 = update trabajo extra para el pelador
#op 3 = eliminar trabajo extra para el pelador
  	#===========INSERT===============
	IF op=1 THEN 
      #Generamos el id de la tabla pelador_extra
      set @idE= concat(emb, (SELECT COUNT(pelador_extra.id)FROM pelador_extra, bolsas_pelador where bolsas_pelador.id=pelador_extra.id_bolsaspelador and bolsas_pelador.id_embarque=emb)+1);
      #Buscamos si el pelador está en la lista de bolsas pelador
      SET @busPelador = (SELECT id FROM bolsas_pelador WHERE id_embarque=emb AND id_pelador=idP);

      #Si existe en la tabla bolsas pelador...
      IF @busPelador>0 THEN 
      
          #Insertamos en la tabla pelador_extra
         	INSERT INTO pelador_extra(id, id_bolsaspelador, trabajo, concepto, pago, fecha) VALUES(@idE, @busPelador, trab, con, pag, fech);
          #Modificamos el estado de tabla de bolsas pelador y sumamos el pago
          UPDATE bolsas_pelador set bolsas_pelador.pago_pe=bolsas_pelador.pago_pe+pag, bolsas_pelador.estado=trab WHERE bolsas_pelador.id=@busPelador;

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
        INSERT INTO `bolsas_pelador`(`id`, `id_pelador`, `id_embarque`, `fecha_trabajo_pe`, `cantidad_bolsas_pe`, `pago_pe`, `estado`) VALUES (@idBolP, idp, emb, fech, 0, pag, trab);

        #Insertamos en pelador extra
        INSERT into pelador_extra(id, id_bolsaspelador, trabajo,concepto, pago, fecha) values (@idE, @idBolP, trab, con, pag, fech);

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
    
    UPDATE pelador_extra SET pelador_extra.pago=0, pelador_extra.fecha='', pelador_extra.concepto='', pelador_extra.trabajo=0 WHERE id=id_extra;
    
    UPDATE bolsas_pelador SET  bolsas_pelador.estado=0 WHERE id=idBP;
    
	END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoBo` (IN `embarque` INT, IN `bolId` INT, IN `fechaT` DATE, IN `pag` FLOAT)  BEGIN
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
            UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoExtra` (IN `opc` INT, IN `embarque` INT, IN `idBol` INT, IN `act` VARCHAR(100), IN `pag` FLOAT, IN `fech` DATE, IN `id_extra` INT, IN `id_bb` INT)  BEGIN
	# Opc 1 es registro
    # Opc 2 es modificar
    # Opc 3 es eliminar 
	
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=embarque;
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
                UPDATE `embarque` SET total_gastos=total_gastos+@pagoNew WHERE id=embarque;
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
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
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
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
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
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
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
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
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
       	UPDATE `embarque` SET total_gastos=total_gastos-pag WHERE id=embarque;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `regTrabajoPT` (IN `embarque` INT, IN `fechaT` DATE, IN `pag` FLOAT, IN `planId` INT)  BEGIN
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
            	INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaUno`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
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
            
        ELSEIF @fechaEmb=1 THEN
        -- Dia 2
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaDos FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaDos=diaDos+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
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
            	INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaDos`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
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
                    UPDATE `embarque` SET total_gastos=total_gastos+pag WHERE id=embarque;
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
                INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaCuatro`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
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
        
        ELSEIF @fechaEmb=4 THEN
        -- Dia 5
            IF @busPlanilla>0 THEN
            	SET @pagExis=(SELECT diaCinco FROM bolsas_toston WHERE id_embarque=embarque);
                IF @pagExis=0 THEN
            		UPDATE bolsas_toston SET diaCinco=diaCinco+pag, pago=pago+pag WHERE id=@busPlanilla;
                    
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
                INSERT INTO `bolsas_toston`(`id`, `id_planilla`, `id_embarque`, `fecha`, `diaCinco`,  `pago`) VALUES (@idNew, planId, embarque, fechaT, pag, pag);
                
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
        
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `rendimiento` (IN `id_e` INT(11))  NO SQL
BEGIN
SET @peso=(select sum(fruta.peso_kg) from fruta where fruta.id_embarque=id_e);
            set @t= @peso*0.001;
            set @bolsas=(SELECT embarque.cant_bolsas_embarque from embarque where embarque.id =id_e);            
            SELECT embarque.fecha_inicio, embarque.fecha_fin, embarque.cant_bolsas_embarque as cant , @t as peso, @bolsas/@t as rendimiento FROM embarque INNER JOIN gastos_embarque on embarque.id=gastos_embarque.id_embarque where embarque.id=id_e LIMIT 1;
END$$

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
        
        SET @idNew = CONCAT(embarque, (SELECT COUNT(prestamos.id)FROM prestamos, fruta WHERE fruta.id=prestamos.id_fruta AND fruta.id_embarque=embarque)+1);
        
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_pesos` (IN `id_e` INT, IN `cant` FLOAT)  NO SQL
    COMMENT 'Actualizar el saldo total cada que se actualice gastos_embarque'
BEGIN
	set @exist=(SELECT pesos.id FROM pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id WHERE cuenta_pesos.id_emb= id_e ORDER BY pesos.id DESC LIMIT 1);
    
    set @id_cuenta=(select id_cuenta from pesos INNER JOIN cuenta_pesos on pesos.id_cuenta=cuenta_pesos.id where cuenta_pesos.id_emb=id_e ORDER BY pesos.id_cuenta desc LIMIT 1);
    
    
    	UPDATE pesos SET gastos_embarque=gastos_embarque+cant where pesos.id=@exist;
    	UPDATE cuenta_pesos SET cuenta_pesos.total_egreso=cuenta_pesos.total_egreso+cant where cuenta_pesos.id_emb=id_e;
    	UPDATE cuenta_pesos SET cuenta_pesos.total_saldo= cuenta_pesos.total_saldo-cant where cuenta_pesos.id_emb=id_e;
    
    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmb` (IN `id_e` INT)  NO SQL
SELECT `id`, DATE_ADD(fecha_inicio, INTERVAL dia_actual DAY) as fecha_inicio, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, toneladas FROM `embarque` WHERE id =id_e$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verEmbarque` ()  NO SQL
SELECT id, fecha_inicio, cant_bolsas_embarque FROM embarque WHERE fecha_fin='0000-00-00' ORDER BY id ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaB` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGBolseros` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `bolseros`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaGPeladores` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaOProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m` FROM `productores` ORDER BY id ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaP` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `Tipo` FROM `peladores`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verListaProd` ()  NO SQL
SELECT `id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `foto` FROM `productores`$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `banco`
--

CREATE TABLE `banco` (
  `id` int(11) NOT NULL,
  `saldoBanco` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas`
--

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
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 222.17, 0, 1),
('762', '761', '', 0.00, 0.00, 0.00, 0, 0),
('763', '761', '', 0.00, 0.00, 0.00, 0, 0),
('764', '761', '', 0.00, 0.00, 0.00, 0, 0),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 222.17, 0, 1),
('772', '771', 'GE77', 0.00, 22.00, 200.17, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_bolsero`
--

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
('771', 1, 77, '2020-07-24', 400.00, 400.00, 300.00, 400.00, 0.00, 0, 1500, 0, NULL),
('772', 7, 77, '2020-07-24', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('773', 9, 77, '2020-07-24', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('774', 3, 77, '2020-07-25', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('775', 5, 77, '2020-07-24', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL),
('776', 2, 77, '2020-07-24', 300.00, 300.00, 300.00, 0.00, 0.00, 0, 900, 0, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_diarias`
--

CREATE TABLE `bolsas_diarias` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `numero` int(5) NOT NULL,
  `id_embarque` int(11) NOT NULL,
  `hora` varchar(15) NOT NULL,
  `fecha` date NOT NULL,
  `pelador` int(11) NOT NULL,
  `id_bolsero` varchar(10) NOT NULL,
  `id_productor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolsas_diarias`
--

INSERT INTO `bolsas_diarias` (`id`, `numero`, `id_embarque`, `hora`, `fecha`, `pelador`, `id_bolsero`, `id_productor`) VALUES
('771', 1, 77, '02:46:59 PM', '2020-07-25', 1, '3', 7),
('7710', 10, 77, '03:03:00 PM', '2020-07-25', 9, '3', 8),
('7711', 11, 77, '02:40:27 PM', '2020-07-26', 1, '7', 6),
('7712', 12, 77, '02:44:33 PM', '2020-07-26', 3, '3', 11),
('772', 2, 77, '02:17:39 PM', '2020-07-25', 2, '3', 11),
('773', 3, 77, '02:49:37 PM', '2020-07-25', 10, '3', 12),
('774', 4, 77, '02:50:39 PM', '2020-07-25', 12, '3', 12),
('775', 5, 77, '02:53:56 PM', '2020-07-25', 6, '3', 8),
('776', 6, 77, '02:54:14 PM', '2020-07-25', 15, '3', 6),
('777', 7, 77, '02:57:35 PM', '2020-07-25', 2, '3', 6),
('778', 8, 77, '02:57:46 PM', '2020-07-25', 5, '3', 8),
('779', 9, 77, '03:02:49 PM', '2020-07-25', 5, '3', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_pelador`
--

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
('771', 2, 77, '2020-07-25', 2, 50, 0),
('7710', 1, 77, '2020-07-26', 1, 25, 0),
('7711', 3, 77, '2020-07-26', 1, 25, 0),
('772', 1, 77, '2020-07-25', 1, 25, 0),
('773', 10, 77, '2020-07-25', 3, 75, 0),
('774', 12, 77, '2020-07-25', 1, 25, 0),
('775', 6, 77, '2020-07-25', 1, 25, 0),
('776', 15, 77, '2020-07-25', 1, 25, 0),
('777', 5, 77, '2020-07-25', 2, 50, 0),
('778', 9, 77, '2020-07-25', 1, 25, 0),
('779', 11, 77, '2020-07-25', 0, 250, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsas_toston`
--

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
('771', 4, 77, '2020-07-25', 0.00, 1000.00, 0.00, 0.00, 0.00, 1000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolseros`
--

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
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `bolseros`
--

INSERT INTO `bolseros` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `foto`) VALUES
(1, 'GERSON', 'RIVERA', 'ALVAREZ', 0, '', 'CUNDUACAN', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'BENY', 'CALDERON', 'AGUILAR', 0, '', 'EL CARMEN', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'NOE', 'RODRIGUEZ', 'GONZALEZ', 0, '', 'PLATANO Y CACAO 2DA', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'LUIS ARTURO', 'LICONA', 'RODRIGUEZ', 0, '', 'CUNDUACAN', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'JUAN ANTONIO', 'RODRIGUEZ', 'ROMERO', 0, '', 'CUNDUACAN', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'DANIEL ANTONIO', 'ENRRIQUE', 'DE LOS SANTOS', 0, '', 'MORELITOS', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(7, 'ELEAZAR', 'PEREZ', 'DIAZ', 0, '', 'CUMUAPA 1RA', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(8, 'MISAEL', 'SANCHEZ', 'MARTINEZ', 0, '', 'CUMUAPA 1RA', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'PEDRO', 'LOPEZ', 'MARTINEZ', 0, '', 'CUMUAPA 1RA', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'OSVALDO', 'PEREZ', 'MORALES', 0, '', 'CUMUAPA 1RA', '', 2, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bolsero_extra`
--

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
('771', 'JOSE', 'ANTONIO', 1, '0', '-', '-', 'BOLSERO', 1500, 77, '2020-07-25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_bolsas`
--

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
('761', 76, 0.00, 0.00, 222.17),
('771', 77, 0.00, 22.00, 200.17);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_dolares`
--

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
('761', 76, 0.00, 0.00, 15088.50),
('771', 77, 0.00, 0.00, 15088.50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta_pesos`
--

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
('761', 76, 0.00, 0.00, 11240.38),
('771', 77, 0.00, 191071.59, -179831.21),
('781', 78, 0.00, 0.00, 0.00),
('791', 79, 0.00, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallesbanco`
--

CREATE TABLE `detallesbanco` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `concepto` varchar(50) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `ingreso` float DEFAULT NULL,
  `egreso` float DEFAULT NULL,
  `saldo` float NOT NULL,
  `id_saldo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dolares`
--

CREATE TABLE `dolares` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_cuentaD` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
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
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 15088.50, 0.0000, 0, 1),
('762', '761', '', 0.00, 0.00, 0.00, 0.0000, 0, 0),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 15088.50, 0.0000, 0, 1),
('772', '771', '', 0.00, 0.00, 0.00, 0.0000, 0, 0),
('773', '771', '', 0.00, 0.00, 0.00, 0.0000, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `embarque`
--

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
  `temperatura` int(10) DEFAULT NULL,
  `nombre_conductor` varchar(100) DEFAULT NULL,
  `perdida` int(5) DEFAULT 0,
  `total_gastos` float(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `embarque`
--

INSERT INTO `embarque` (`id`, `fecha_inicio`, `dia_actual`, `fecha_fin`, `cant_bolsas_embarque`, `toneladas`, `contenedor`, `no_sello`, `cuentas`, `matricula`, `temperatura`, `nombre_conductor`, `perdida`, `total_gastos`) VALUES
(76, '2020-01-01', 0, '2020-01-01', 0, 0, '0', '0', 1, '0', 0, '-', 0, 0.00),
(77, '2020-07-24', 2, '0000-00-00', 12, 0, '', '', 0, '', 0, '', 0, 191071.59),
(78, '2020-07-24', 0, '0000-00-00', 0, 0, '', '', 0, '', 0, '', 0, 0.00),
(79, '2020-08-16', 0, '0000-00-00', 0, 0, '', '', 0, '', 0, '', 0, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `extra`
--

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
('771', 1, 12250.2, 4, 49000.8, 0, 77),
('7710', 10, 1198.2, 4, 4792.8, 1, 77),
('7711', 11, 191.4, 4, 765.6, 2, 77),
('7712', 12, 1672.2, 4, 6688.8, 4, 77),
('7713', 13, 4063.8, 4, 16255.2, 0, 77),
('7714', 14, 8811.4, 4, 35245.6, 0, 77),
('772', 2, 5364, 4, 21456, 0, 77),
('773', 3, 6428.6, 4, 25714.4, 0, 77),
('774', 4, 1338, 4, 5352, 0, 77),
('775', 5, 1613.6, 4, 6454.4, 0, 77),
('776', 6, 1805, 4, 7220, 3, 77),
('777', 7, 1243.4, 4, 4973.6, 1, 77),
('778', 8, 739.4, 4, 2957.6, 3, 77),
('779', 9, 711.2, 4, 2844.8, 0, 77);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos`
--

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
(29, 'FUNGICIDA PRODUCTORES ABONO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos_embarque`
--

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
('761', 76, 8, 0.00, ''),
('762', 76, 5, 0.00, ''),
('771', 77, 1, 182346.59, ''),
('772', 77, 29, 7375.00, ''),
('773', 77, 23, 0.00, ''),
('774', 77, 24, 0.00, ''),
('775', 77, 8, 1000.00, ''),
('776', 77, 16, 0.00, ''),
('777', 77, 3, 300.00, ''),
('778', 77, 2, 50.00, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `peladores`
--

CREATE TABLE `peladores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(11) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) NOT NULL,
  `edad` int(2) DEFAULT 0,
  `telefono` varchar(12) DEFAULT NULL,
  `direccion` varchar(100) NOT NULL,
  `no_cuenta` varchar(20) DEFAULT NULL,
  `Tipo` int(2) NOT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `peladores`
--

INSERT INTO `peladores` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `Tipo`, `foto`) VALUES
(1, 'YOMAILI', 'HERNANDEZ', 'DE DIOS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'JOSE MANUEL', 'MALDONADO', 'A', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'ELMER EBERT', 'GARCIA', 'MONZON', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'SHEILA KARE', 'ARIAS', 'LARA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'BEATRIZ', 'BERA', 'ANTONIO', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'DANIELA JAS', 'LOPEZ', 'VELAZQUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(7, 'CLARIBEL', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(8, 'KEVIN GERAR', 'ARIAS', 'ZENTELLA', 0, '', 'CUNDUACAN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'WALTER', 'MIRANDA', 'SUAREZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'HIGINIO', 'RODRIGUEZ', 'VASCONCELOS', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(11, 'PERLA RUBI', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(12, 'MARIA DE LO', 'VELAZQUEZ', 'RODRIGUEZ', 0, '', 'HUIMANGO 2DA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(13, 'RICARDO', 'OVANDO', 'FRANCISCO', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(14, 'GUADALUPE', 'OVANDO', 'FRANCISCO', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(15, 'CECILIA', 'FRANCISCO', 'DE JESUS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(16, 'DANIEL', 'ENRRIQUE', 'DE LOS SANTOS', 0, '', 'MORELITOS', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(17, 'EMILI', 'SENTELLA', 'LOPEZ', 0, '', 'MORELITOS', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(18, 'JOSE ALBERT', 'RAMON', 'LAZARO', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(19, 'MARIA ESTEL', 'FRANCISCO', 'DE JESUS', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(20, 'EDITH', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(21, 'ZOILA', 'VALENCIA', 'BAUTISTA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(22, 'DANIELA CRI', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(23, 'MARINA', 'LAZARO', 'RAMOS', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(24, 'ROSA ISELA', 'GONZALEZ', 'VALENCIA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(25, 'ANGEL MATEO', 'GOMEZ', 'GUTIERREZ', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(26, 'LINDA ANAI', 'GARCIA', 'GUTIERREZ', 0, '', 'JALPA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(27, 'TANIA SUGEY', 'VASCONCELOS', 'LAZARO', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(28, 'YADIRA', 'ROMERO', 'GARCIA', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(29, 'SURI DANIEL', 'LAZARO', 'ROMERO', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(30, 'ADRIAN DRAW', 'LAZARO', 'CONTRERAS', 0, '', 'GREGORIO MENDEZ', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(31, 'LUIS ANGEL', 'MARTIN', 'MAY', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(32, 'SABDIEL', 'MARTIN', 'VOLAINA', 0, '', 'CUMUAPA 1RA', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(33, 'ADAN', 'ALBERTO', 'HERNANDEZ', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(34, 'TEREZA', 'AGUILAR', 'ZAPATA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(35, 'BRAYAN', 'AGUILAR', 'ZAPATA', 0, '', 'EL CARMEN', '', 1, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pelador_extra`
--

CREATE TABLE `pelador_extra` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `id_bolsaspelador` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `trabajo` int(11) NOT NULL,
  `concepto` varchar(30) DEFAULT NULL,
  `pago` float NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `pelador_extra`
--

INSERT INTO `pelador_extra` (`id`, `id_bolsaspelador`, `trabajo`, `concepto`, `pago`, `fecha`) VALUES
('771', '772', 0, '', 0, '0000-00-00'),
('772', '779', 0, '', 0, '0000-00-00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pesos`
--

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
('761', '761', 'SALDO ANTERIOR', 0.00, 0.00, 11240.38, 0.00, '0', 0, 1),
('762', '761', 'GASTOS E76', 0.00, 0.00, 11240.38, 0.00, '0', 0, 1),
('771', '771', 'SALDO ANTERIOR', 0.00, 0.00, 11240.38, 0.00, '0', 0, 1),
('772', '771', 'GASTOS E77', 0.00, 191071.59, -179831.21, 0.00, '0', 0, 1),
('773', '771', '', 1614.24, 0.00, -1310.00, 0.00, '773', 0, 0),
('781', '781', 'SALDO ANTERIOR', 0.00, 0.00, 0.00, 0.00, '0', 0, 1),
('791', '791', 'SALDO ANTERIOR', 0.00, 0.00, 0.00, 0.00, '0', 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `planilla_toston`
--

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
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `planilla_toston`
--

INSERT INTO `planilla_toston` (`id`, `nombre`, `ap_p`, `ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `tipo`, `foto`) VALUES
(1, 'MIGUEL', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'WILLIAN JOSE', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'YOSMAR', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'EDGAR', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'ANDRES', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'ARMANDO', '', '', 0, '', '-', '', 3, 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio_compra`
--

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

CREATE TABLE `prestamos` (
  `id` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
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
('771', '771', 12100, 0, 0, 4, 0, 0, 3025, 0, 0, 9075, 0, 0, 3025, 0, 0),
('772', '772', 1700, 0, 0, 4, 0, 0, 425, 0, 0, 1275, 0, 0, 425, 0, 0),
('773', '773', 3400, 0, 0, 4, 0, 0, 850, 0, 0, 2550, 0, 0, 850, 0, 0),
('774', '774', 7000, 0, 0, 4, 0, 0, 1750, 0, 0, 5250, 0, 0, 1750, 0, 0),
('775', '775', 3600, 0, 0, 4, 0, 0, 900, 0, 0, 2700, 0, 0, 900, 0, 0),
('776', '779', 1700, 0, 0, 4, 0, 0, 425, 0, 0, 1275, 0, 0, 425, 0, 0),
('777', '7713', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productores`
--

CREATE TABLE `productores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `Ap_p` varchar(255) NOT NULL,
  `Ap_m` varchar(255) DEFAULT '',
  `edad` int(2) DEFAULT 0,
  `telefono` varchar(12) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT '',
  `no_cuenta` varchar(20) DEFAULT NULL,
  `foto` varchar(155) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `productores`
--

INSERT INTO `productores` (`id`, `nombre`, `Ap_p`, `Ap_m`, `edad`, `telefono`, `direccion`, `no_cuenta`, `foto`) VALUES
(1, 'LUIS', 'E', 'TORRES', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(2, 'NAIN', 'PEREZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(3, 'SANTIAGO', 'ALMEIDA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(4, 'BISMAR', 'LAZARO', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(5, 'JESUS', 'PALMA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(6, 'ROBERTO', 'MARQUEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(7, 'ULDARIO', 'SANCHEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(8, 'JOSE', 'DE LA LUZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(9, 'GENARO', 'COLORADO', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(10, 'LAZARO', 'MIRANDA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(11, 'JOSE ANTONIO', 'ARIAS', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(12, 'DANIEL JESUS', 'SEGURA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(13, 'MARCOS', 'OCHOA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(14, 'ADALBERTO', 'MARTINEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(15, 'SANTIAGO', 'LUNA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(16, 'ALBIN', 'SANCHEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(17, 'NAIN', 'CALIX', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(18, 'CIRILO', 'MORALES', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(19, 'NOE', 'RIVERA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(20, 'GAMALIEL', 'SANCHEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(21, 'FEDERICO', 'REGLA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(22, 'BERNAVE', 'RAMOS', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(23, 'INOCENTE', 'CALIX', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(24, 'ANDRES', 'ESTRADA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(25, 'ADONAY', 'ARIAS', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(26, 'OSEAS', 'SANCHEZ', '', 0, '', '', ' ', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(27, 'JOSE MANUEL', 'GARCIA', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(28, 'MANACE', 'CALIX', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(29, 'EZEQUIEL', 'MARTINEZ', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(30, 'RAYMUNDO', 'CAMPOS', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png'),
(31, 'PRADO', 'VERDE', '', 0, '', '', '', 'http://localhost/PLATANERATAB/vistas/assets/avatars/icon.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productor_fruta`
--

CREATE TABLE `productor_fruta` (
  `id` varchar(11) NOT NULL,
  `id_fruta` varchar(11) CHARACTER SET latin1 COLLATE latin1_spanish_ci NOT NULL,
  `peso` float NOT NULL,
  `foto` varchar(200) NOT NULL,
  `fecha_compra` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `productor_fruta`
--

INSERT INTO `productor_fruta` (`id`, `id_fruta`, `peso`, `foto`, `fecha_compra`) VALUES
('771', '771', 12250.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7710', '7710', 1198.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7711', '7711', 191.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7712', '7712', 1672.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7713', '7713', 4063.8, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7714', '7714', 8811.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('7715', '776', 240, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-26'),
('772', '772', 5364, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('773', '773', 6428.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('774', '774', 1338, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('775', '775', 1613.6, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('776', '776', 1565, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('777', '777', 1243.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('778', '778', 739.4, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24'),
('779', '779', 711.2, 'http://localhost/PLATANERATAB/vistas/assets/icons/bananas.png', '2020-07-24');

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
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `user`, `password`, `nombre`, `genero`, `tipo`, `estado`) VALUES
(1, 'admin', 'eGVlUnJPNng4d09uZ0w3aFlXODFpUT09', 'Administrador Admin', 'Masculino', 1, 'ALTA'),
(2, 'root', 'eU9KT0h4ek44NDhLcUxqc1ZZZ0JxQT09', 'Capturista Root', 'Masculino', 2, 'ALTA');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `banco`
--
ALTER TABLE `banco`
  ADD PRIMARY KEY (`id`);

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
-- Indices de la tabla `detallesbanco`
--
ALTER TABLE `detallesbanco`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_saldo` (`id_saldo`);

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
-- AUTO_INCREMENT de la tabla `banco`
--
ALTER TABLE `banco`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `bolseros`
--
ALTER TABLE `bolseros`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `embarque`
--
ALTER TABLE `embarque`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT de la tabla `gastos`
--
ALTER TABLE `gastos`
  MODIFY `id_gasto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `peladores`
--
ALTER TABLE `peladores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `planilla_toston`
--
ALTER TABLE `planilla_toston`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `precio_compra`
--
ALTER TABLE `precio_compra`
  MODIFY `id_precio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `productores`
--
ALTER TABLE `productores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
-- Filtros para la tabla `detallesbanco`
--
ALTER TABLE `detallesbanco`
  ADD CONSTRAINT `detallesbanco_ibfk_1` FOREIGN KEY (`id_saldo`) REFERENCES `banco` (`id`);

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
