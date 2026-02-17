create or replace NONEDITIONABLE TRIGGER InsertFormules
BEFORE INSERT ON Formules FOR EACH ROW
BEGIN
    IF :NEW.nbJours < 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'NbJours doit etre positif');
    END IF;
    IF :NEW.forfaitKm < 0 THEN
        RAISE_APPLICATION_ERROR(-20002,'ForfaitKm doit etre positif');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;