CREATE OR REPLACE TRIGGER InsertionTarifs
BEFORE INSERT ON Tarifs FOR EACH ROW
DECLARE 
    v_numCat Categories.NumCat%TYPE;
    v_formul Formules.formule%TYPE;
BEGIN
    SELECT COUNT(*) INTO v_numCat FROM Categories WHERE NumCat = :NEW.NumCat;
    IF v_numCat = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001,'La numCat n''existe pas dans Categories');
    END IF;
    SELECT COUNT(*) INTO v_formul FROM Formules WHERE formule = :NEW.formule;
    IF v_formul = 0 THEN 
        RAISE_APPLICATION_ERROR(-20002,'La formule n''existe pas dans Formules');
    END IF;
    IF :NEW.Tarif < 0 THEN
        RAISE_APPLICATION_ERROR(-20003,'Tarif doit etre positif');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/