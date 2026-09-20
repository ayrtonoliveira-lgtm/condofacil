"""Demonstracao reproduzivel: python database/executar.py (Python 3.10+).

Gera um banco NOVO com nome exclusivo em database/gerados; nao apaga bancos.
Utiliza apenas a biblioteca padrao. Nenhuma conexao externa e realizada.
"""
from pathlib import Path
import json
import sqlite3
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def iniciar(con):
    con.execute('PRAGMA foreign_keys=ON')
    con.executescript((ROOT / '01_schema.sql').read_text(encoding='utf-8'))
    con.executescript((ROOT / '02_dados.sql').read_text(encoding='utf-8'))


def verificar(con):
    resultados = []

    def rejeita(nome, sql, parametros, erro):
        con.execute('SAVEPOINT caso')
        try:
            con.execute(sql, parametros)
        except sqlite3.IntegrityError as exc:
            assert erro in str(exc), (nome, str(exc))
            resultados.append({'teste': nome, 'resultado': 'PASS', 'evidencia': str(exc)})
        else:
            raise AssertionError(nome + ': operacao deveria ser recusada')
        finally:
            con.execute('ROLLBACK TO caso')
            con.execute('RELEASE caso')

    ins = 'INSERT INTO reserva VALUES (?,?,?,?,?,?,?)'
    rejeita('Reserva sobreposta',ins,(10,3,1,'2026-10-10',660,780,'ativa'),'Horario indisponivel')
    rejeita('Conflito em UPDATE','UPDATE reserva SET inicio_min=660 WHERE id=3',(),'Horario indisponivel')
    rejeita('Usuario inexistente',ins,(10,999,3,'2026-10-10',600,720,'ativa'),'FOREIGN KEY')
    rejeita('Horario invertido',ins,(10,2,3,'2026-10-10',720,600,'ativa'),'CHECK')
    rejeita('Horario fora de 08h-22h',ins,(10,2,3,'2026-10-10',470,600,'ativa'),'CHECK')
    rejeita('Data inexistente',ins,(10,2,3,'2026-02-30',600,720,'ativa'),'CHECK')
    rejeita('Email duplicado sem distinguir maiusculas',
            'INSERT INTO usuario VALUES (?,?,?,?)',(10,'Outro Demo','MARINA@example.invalid','morador'),'UNIQUE')
    rejeita('Perfil invalido','INSERT INTO usuario VALUES (?,?,?,?)',
            (10,'Outro Demo','outro@example.invalid','superuser'),'CHECK')
    rejeita('Excluir usuario referenciado','DELETE FROM usuario WHERE id=2',(),'FOREIGN KEY')
    rejeita('Excluir area referenciada','DELETE FROM area_comum WHERE id=1',(),'FOREIGN KEY')
    rejeita('Texto vazio','INSERT INTO mensagem VALUES (?,?,?,?)',(10,2,'   ','Texto'),'CHECK')
    rejeita('Tipo incorreto em tabela STRICT','INSERT INTO area_comum VALUES (?,?,?)',
            (10,'Teste','muitas'),'cannot store TEXT')

    con.execute('SAVEPOINT positivos')
    con.execute(ins,(10,2,2,'2026-10-10',720,840,'ativa'))
    resultados.append({'teste':'Reutilizar horario cancelado','resultado':'PASS'})
    rejeita('Reativar reserva conflitante',"UPDATE reserva SET status='ativa' WHERE id=2",(),'Horario indisponivel')
    con.execute(ins,(11,2,3,'2026-10-10',600,720,'ativa'))
    resultados.append({'teste':'Mesmo horario em outra area','resultado':'PASS'})
    con.execute(ins,(12,2,1,'2026-10-11',600,720,'ativa'))
    resultados.append({'teste':'Mesmo horario em outra data','resultado':'PASS'})
    con.execute('ROLLBACK TO positivos')
    con.execute('RELEASE positivos')

    checks = [
        ('Insercao de reserva consecutiva',con.execute('SELECT inicio_min FROM reserva WHERE id=3').fetchone()==(720,)),
        ('Atualizacao para cancelada',con.execute('SELECT status FROM reserva WHERE id=2').fetchone()==('cancelada',)),
        ('Remocao da mensagem de teste',con.execute('SELECT COUNT(*) FROM mensagem WHERE id=99').fetchone()==(0,)),
        ('Remocao em cascata da resposta',con.execute('SELECT COUNT(*) FROM resposta WHERE id=99').fetchone()==(0,)),
        ('Integridade referencial',con.execute('PRAGMA foreign_key_check').fetchall()==[]),
        ('Integridade do banco',con.execute('PRAGMA integrity_check').fetchone()==('ok',)),
    ]
    for nome, passou in checks:
        assert passou, nome
        resultados.append({'teste':nome,'resultado':'PASS'})
    return resultados


def main():
    if sqlite3.sqlite_version_info < (3,37,0):
        raise SystemExit('Necessario SQLite >= 3.37 para tabelas STRICT.')
    output = ROOT/'gerados'
    output.mkdir(exist_ok=True)
    run = Path(tempfile.mkdtemp(prefix='execucao-',dir=output))
    with sqlite3.connect(run/'condofacil.sqlite3') as con:
        iniciar(con)
        con.executescript((ROOT/'03_operacoes.sql').read_text(encoding='utf-8'))
        resultados = verificar(con)
        agenda=con.execute("""SELECT r.id,u.nome,a.nome,r.data,
        printf('%02d:%02d',r.inicio_min/60,r.inicio_min%60),
        printf('%02d:%02d',r.fim_min/60,r.fim_min%60)
        FROM reserva r JOIN usuario u ON u.id=r.usuario_id
        JOIN area_comum a ON a.id=r.area_id WHERE r.status='ativa' ORDER BY r.id""").fetchall()
        ocupacao=con.execute("""SELECT a.nome,COUNT(r.id) FROM area_comum a
        LEFT JOIN reserva r ON r.area_id=a.id AND r.status='ativa'
        GROUP BY a.id,a.nome ORDER BY a.id""").fetchall()
        dados={'sqlite':sqlite3.sqlite_version,'python':sys.version.split()[0],
               'testes':resultados,'total':len(resultados),'agenda':agenda,'ocupacao':ocupacao,
               'contagens':{t:con.execute('SELECT COUNT(*) FROM '+t).fetchone()[0]
                           for t in ['usuario','area_comum','reserva','aviso','mensagem','resposta']}}
        (run/'resultado.json').write_text(json.dumps(dados,ensure_ascii=False,indent=2),encoding='utf-8')
        print(json.dumps(dados,ensure_ascii=False,indent=2))
        print('Banco e evidencias:',run)


if __name__=='__main__':
    main()
