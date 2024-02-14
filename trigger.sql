drop trigger if exists check_partecipazione_rif on partecipazione;
drop function if exists check_partecipazione_rif();

create function check_partecipazione_rif() returns trigger as $BODY$
begin
	
	if((select data_fine from edizione_progetto where codice=new.edizione_progetto)-current_date>0) then
		if(exists(select * from partecipazione join edizione_progetto on edizione_progetto=codice where rifugiato=new.rifugiato and codice<>new.edizione_progetto and (data_fine-current_date>0))) then
		   raise exception 'impossibile assegnare rifugiato % a progetto %',new.rifugiato,new.edizione_progetto;
		end if;
	end if;
	return new;
end $BODY$ language plpgsql;

create trigger check_partecipazione_rif
after insert on partecipazione 
for each row execute procedure check_partecipazione_rif();


drop trigger if exists check_lingua on rifugiato;
drop function if exists lingua_rifugiato();

create function lingua_rifugiato() returns trigger as $BODY$
begin
if(not exists(select * from conoscenza where rifugiato = new.documento_identita)) then
raise exception 'Inserire lingua';
end if;
return new;
end
$BODY$ language plpgsql;

create trigger check_lingua
after insert on rifugiato
for each row execute procedure lingua_rifugiato();


drop trigger if exists aggiorna_partecipanti on partecipazione;
drop function if exists aggiorna_partecipanti();

create function aggiorna_partecipanti() returns trigger as $BODY$
declare
	c integer;
begin
	select count(*) into c from partecipazione where edizione_progetto=new.edizione_progetto;
	
	update edizione_progetto
	set numero_partecipanti=c
	where codice=new.edizione_progetto;
return new;
end $BODY$ language plpgsql;

create trigger aggiorna_partecipanti
after insert on partecipazione
for each row execute procedure aggiorna_partecipanti();


drop trigger if exists verifica_capacita on partecipazione;
drop function if exists verifica_capacita();

create function verifica_capacita() returns trigger as $BODY$
declare
	part integer;
	cap integer;
begin
	select numero_partecipanti into part from edizione_progetto where codice=new.edizione_progetto;
	select capienza into cap
		from struttura_alloggiativa join edizione_progetto on cis=struttura
		where codice=new.edizione_progetto;
	if((part)>cap) then
		raise exception 'struttura alloggiativa piena';
	end if;
	return new;
end $BODY$ language plpgsql;

create trigger verifica_capacita
after insert on partecipazione
for each row execute procedure verifica_capacita();


drop trigger if exists check_edizione on edizione_progetto;
drop function if exists check_edizione();

create function check_edizione() returns trigger as $BODY$
begin
	if(not exists(select * from offerta where edizione_progetto = new.codice) and
	  not exists(select * from proposta where edizione_progetto = new.codice)) then
		raise exception 'edizione progetto deve offrire almeno un corso o un servizio';
	end if;
	return new;
end $BODY$ language plpgsql;

create trigger check_edizione
after insert on edizione_progetto
for each row execute procedure check_edizione();


drop trigger if exists check_vulnerabilita on edizione_progetto;
drop function if exists check_vulnerabilita;

create function check_vulnerabilita() returns trigger as $BODY$
begin
	if(exists(select * from progetto where codice=new.progetto and tipologia='Vulnerabilita' and vulnerabilita='Disabilita')) then
	   if(select ospitalita_disabili from struttura_alloggiativa where new.struttura=cis) then
	   		return new;
		else
			raise exception 'struttura non in grado di ospitare disabili';
	   end if;
	end if;
	return new;
end $BODY$ language plpgsql;	   

create trigger check_vulnerabilita
after insert on edizione_progetto
for each row execute procedure check_vulnerabilita();






