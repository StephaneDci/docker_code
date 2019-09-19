# coding:utf-8

import random


# Creation d'une table avec date automatique à l'heure d'insertion
def create_table(con, table):
    print("\n[+] Creation de la table KV : %s ..." % table)
    cur = con.cursor()
    statement1 = """ CREATE TABLE IF NOT EXISTS %s """ % table
    statement2 = """
        (
         id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
         operation TEXT,
         key TEXT,
         val TEXT,
         url TEXT,
         date DATETIME NOT NULL DEFAULT (strftime('%d/%m/%Y %H:%M:%S', 'now', 'localtime'))
        )
    """
    statement = statement1 + statement2
    cur.execute(statement)
    con.commit()


def drop_table(con, table):
    print("\n---entering drop_table---\n")
    print("\t[+] Suppression de la table %s ..." % table)
    statement = """ DROP TABLE %s """
    print(statement % table)
    cur = con.cursor()
    cur.execute(statement % table)
    con.commit()
    print("\n---end of drop_table---\n")


# Fonction de Remplissage aléatoire de x pers
def populate_db(con, table, xpers):
    print("\n---entering populate_db---\n")
    print("\t[+] Populate database with %s entries..." % xpers)
    cur = con.cursor()
    randname = ['Maurice', 'Paul', 'Boubakar', 'Kamori', 'Nicolem', 'Lea', 'Bob', 'Grunt', 'Spider', 'Minotor']
    statement1 = """ INSERT INTO %s (key, val) """ % table
    for it in range(xpers):
        age = random.randrange(0, 99)
        prenom = randname[(age % (len(randname)))]
        statement2 = """ VALUES('%s', '%s')""" % (prenom, age)
        statement = statement1 + statement2
        print("\tStatement: ", statement)
        cur.execute(statement)
    con.commit()
    print("\n---end of populate_db---\n")


def display_table(con, table):
    print("\n---entering display_table---\n")
    print("\t[+] Affichage du Contenu de la Table %s : \n", table)
    cur = con.cursor()
    statement = """SELECT id, operation, key, val, date FROM %s"""
    cur.execute(statement % table)
    for row in cur:
        print('{0} : {1], {2}, {3}  - updated at : {4} '.format(row[0], row[1], row[2], row[3]), row[4])
    print("\n---end of display_table---\n")


def insert_into_kv(con, table, operation, key, val, url=""):
    print("\n---entering insert_into_kv---\n")
    cur = con.cursor()
    statement = """INSERT INTO %s(operation, key, val, url) VALUES("%s", "%s", "%s", "%s")""" % (table, operation, key, val, url)
    print("\tStatement: ", statement)
    cur.execute(statement)
    con.commit()
    print("\n---end of insert_into_kv---\n")
