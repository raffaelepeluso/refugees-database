select ent.nazione, count(*) as progetti
from ente ent join progetto prog on ent.codice_fiscale = prog.ente_assegnatario
join edizione_progetto ed on ed.progetto = prog.codice
where extract (year from ed.data_fine) = 2022
group by ent.nazione


select serv.attivita, serv.tipologia, serv.individuale, serv.luogo
from servizio serv
where exists
    (select * from edizione_progetto ed where ed.progetto='EU0x762192') 
    and not exists
    (select ed.codice from edizione_progetto ed
    where ed.progetto = 'EU0x762192' and ed.codice not in(
        select off1.edizione_progetto from offerta off1
        where off1.servizio = serv.codice
    )
);


select serv1.attivita as attivita, serv1.luogo, ed1.data_inizio, ed1.data_fine
from rifugiato rif1 join partecipazione part1 on rif1.documento_identita = part1.rifugiato 
join edizione_progetto ed1 on part1.edizione_progetto = ed1.codice
join offerta off1 on off1.edizione_progetto = ed1.codice
join servizio serv1 on serv1.codice = off1.servizio
where rif1.documento_identita = 'IT3476889'
union
select cor2.descrizione as attivita, cor2.luogo, ed2.data_inizio, ed2.data_fine
from rifugiato rif2 join partecipazione part2 on rif2.documento_identita = part2.rifugiato 
join edizione_progetto ed2 on part2.edizione_progetto = ed2.codice
join proposta prop2 on prop2.edizione_progetto = ed2.codice
join corso cor2 on cor2.codice = prop2.corso
where rif2.documento_identita = 'IT3476889'
order by data_inizio;


create view proposta_enti(ente,num_corsi,vulnerabilita) as
    select denominazione,count(distinct corso),prog.vulnerabilita
    from ente join progetto prog on codice_fiscale=ente_assegnatario
        join edizione_progetto ed on prog.codice=ed.progetto
        join proposta prop on ed.codice=prop.edizione_progetto
        where prog.tipologia<>'Ordinario'
    group by codice_fiscale, prog.vulnerabilita ;

select vulnerabilita,ente,num_corsi
from proposta_enti tab
group by vulnerabilita,ente,num_corsi
having num_corsi >= all(select num_corsi from proposta_enti where vulnerabilita=tab.vulnerabilita)
