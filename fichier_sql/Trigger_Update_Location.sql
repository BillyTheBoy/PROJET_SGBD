CREATE OR REPLACE TRIGGER UpdateLocation
BEFORE UPDATE ON LOCATION FOR EACH ROW
DECLARE
    v_km NUMBER;
    c_prixkm  NUMBER;
    f_forfaitkm NUMBER;
BEGIN
    IF :NEW.Numloc!= :OLD.Numloc OR :NEW.Numveh != :OLD.Numveh OR :NEW.Formule != :OLD.Formule OR :NEW.DateDepart != :OLD.DateDepart OR :NEW.Montant != :OLD.Montant THEN
        RAISE_APPLICATION_ERROR(-20001,'La modification ne concerne que KmLoc et DateRetour');
    END IF;
    IF :NEW.DateRetour < :OLD.DateRetour THEN
        RAISE_APPLICATION_ERROR(-20002, 'Attention : la date de retour a été dépassée pour le véhicule : '||:OLD.Numveh);
    END IF;
    
    SELECT prixkm INTO c_prixkm 
    FROM Vehicule V
    JOIN Modeles M ON V.modele = M.modele
    JOIN Categories C ON C.Numcat = M.Numcat
    WHERE V.Numveh = :NEW.Numveh;
    
    SELECT forfaitkm INTO f_forfaitkm
    FROM Formules
    WHERE formule = :NEW.formule;
    
    :NEW.Montant := GREATEST(0,:New.KmLoc - f_forfaitkm) * c_prixkm;
    
    UPDATE Vehicule
    SET 
    km = km + :NEW.Kmloc,
    Nbjoursloc = Nbjoursloc + :New.DateRetour - :New.DateDepart + 1,
    CAV = CAV + :NEW.Montant
    WHERE Numveh = :NEW.Numveh;
    
    SELECT km INTO v_km FROM Vehicule WHERE Numveh = :NEW.Numveh;
    
    IF v_km > 50000 THEN
        UPDATE Vehicule
        SET situation = 'retraite'
        WHERE Numveh = :NEW.Numveh;
        INSERT INTO VehiculeRetraite(numveh,dateRetraite)
        VALUES(:NEW.numveh,:NEW.DateRetour);
        DBMS_OUTPUT.PUT_LINE('Le vehicule numero : '||:NEW.Numveh||'a pris sa retraite');
    ELSE
        UPDATE Vehicule
        SET situation = 'disponible'
        WHERE Numveh = :NEW.Numveh;
    END IF;    
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Pas de données trouvées');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
