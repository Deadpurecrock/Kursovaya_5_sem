CREATE DATABASE  IF NOT EXISTS `rfid_lib` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `rfid_lib`;
-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: rfid_lib
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book` (
  `id_B` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `author` varchar(50) NOT NULL,
  `rfid_B` bigint NOT NULL,
  `isTaken` bit(1) NOT NULL DEFAULT b'0',
  `Visitor_id_V` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_B`),
  KEY `Visitor_id_V` (`Visitor_id_V`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`Visitor_id_V`) REFERENCES `visitor` (`id_V`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `history` (
  `id_H` int NOT NULL AUTO_INCREMENT,
  `date_h` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `stat_old` bit(1) NOT NULL,
  `stat_new` bit(1) NOT NULL,
  `Book_id_B` int NOT NULL,
  PRIMARY KEY (`id_H`),
  KEY `Book_id_B` (`Book_id_B`),
  CONSTRAINT `history_ibfk_1` FOREIGN KEY (`Book_id_B`) REFERENCES `book` (`id_B`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `history`
--

LOCK TABLES `history` WRITE;
/*!40000 ALTER TABLE `history` DISABLE KEYS */;
/*!40000 ALTER TABLE `history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor`
--

DROP TABLE IF EXISTS `visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitor` (
  `id_V` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `birthday` date NOT NULL,
  `email` varchar(100) NOT NULL,
  `rfid_V` bigint NOT NULL,
  PRIMARY KEY (`id_V`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor`
--

LOCK TABLES `visitor` WRITE;
/*!40000 ALTER TABLE `visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'rfid_lib'
--

--
-- Dumping routines for database 'rfid_lib'
--
/*!50003 DROP FUNCTION IF EXISTS `ChangeStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ChangeStatus`(rfid_Vis int, rfid_Book int) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
DECLARE ID INT;
DECLARE IDV INT;
IF EXISTS (SELECT * FROM Book where rfid_B = rfid_Book) then
	SELECT id_B FROM Book WHERE rfid_B = rfid_Book INTO ID;
    IF rfid_Vis = -1 then
		IF (SELECT isTaken FROM Book WHERE id_B = ID) = 0 THEN
			UPDATE Book SET Visitor_id_V = 0 WHERE id_B = ID;
            UPDATE Book SET isTaken = 0 WHERE id_B = ID;
		ELSE
			SIGNAL sqlstate '45000' SET message_text = "Book already has been returned!";
        END IF;
	ELSE 
		IF (SELECT isTaken FROM Book WHERE id_B = ID) = 1 THEN
			SIGNAL sqlstate '45000' SET message_text = "Book already has been borrowed!";
		ELSE
			IF EXISTS (SELECT * FROM Visitor where rfid_V = rfid_Vis) then
				SELECT id_V FROM Visitor WHERE rfid_V = rfid_Vis INTO IDV;
					UPDATE Book SET Visitor_id_V = IDV WHERE id_B = ID;
					UPDATE Book SET isTaken = 1 WHERE id_B = ID;
			ELSE
				SIGNAL sqlstate '45000' SET message_text = "User does not exist in database!";
			END IF;
		END IF;
	END IF;
ELSE
	SIGNAL sqlstate '45000' SET message_text = "This book is not available now or not in stock!";
END IF;
RETURN 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-12-16 18:11:02
