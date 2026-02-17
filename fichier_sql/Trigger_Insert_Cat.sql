CREATE OR REPLACE NONEDITIONABLE TRIGGER InsertCategorie
BEFORE INSERT ON Categories FOR EACH ROW
DECLARE 
    v_categorie NUMBER;
BEGIN
    IF :NEW.NumVeh IS NOT NULL OR :NEW.Categorie IS NULL OR :NEW.PrixKm IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Les parametre ne doit pas etre null OU Vous avez pas droit modifier NumVeh');
    END IF;

    SELECT COUNT(*) INTO v_categorie FROM Categories WHERE categorie = :NEW.categorie;
    IF v_categorie != 0 THEN 
        RAISE_APPLICATION_ERROR(-20002,'La categorie existe déjà');
    END IF;

    :NEW.numCat := num_categorie_sequence.NEXTVAL;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;