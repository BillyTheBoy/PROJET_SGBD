create or replace NONEDITIONABLE TRIGGER SuppressionLocation
BEFORE DELETE ON LOCATION FOR EACH ROW
BEGIN
    IF :OLD.KmLoc != 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'L’annulation ne concerne que les locations dont KmLoc est égal à 0');
    END IF;
    UPDATE Vehicule
    SET situation  = 'disponiblE'
    WHERE numVeh = :OLD.numVeh;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
