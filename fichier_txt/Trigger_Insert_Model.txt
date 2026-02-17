-- Creation d'un trigger pour l'insertion dans Modeles

CREATE OR REPLACE TRIGGER InsertionModeles
BEFORE INSERT ON Modeles FOR EACH ROW
DECLARE 
        v_numCat Categories.numCat%TYPE;
    
BEGIN
    SELECT numCat INTO v_numCat FROM Categories WHERE numCat = :NEW.numCat;
    
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001,'La catégorie n''existe pas');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/
