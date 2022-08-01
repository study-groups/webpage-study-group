import spacy
import sys
nlp = spacy.load("en_core_web_sm")

def doit(stdin): 
    doc=nlp(stdin.read())
    print([tok.text for tok in doc if not tok.is_stop]) 

if __name__ == "__main__":
    doit(sys.stdin)
