#include <bits/stdc++.h>
#include <string>
#include <unordered_map>

#include"lex.yy.c"
using namespace std;
//declarations

#define ID 1007
#define NUM 1008
#define STR 1009
#define REF 1010
#define LPN 1011
#define RPN 1012
#define CRT 1013
#define PLUS 1014
#define ASG 1015
#define EOL 1016
#define INV 1017


//call the value from elexe

int yylex(); //declare yylex()
extern char elexe[]; // get from lex.yy.c
extern FILE *yyin;


// Token handling


struct Token {
    int code;
    string sval;
    int ival;
};
static Token lookahead;


static Token getToken() {
    Token t{};
    int c = yylex();
    t.code = c;
    if (c==ID || c==STR || c==REF) {
        t.sval = string(yytext?yytext:"");
    } else if (c==NUM) {
        t.ival = atoi(yytext?yytext:"0");
    }
    return t;
}

// somehelper func 


static string expostring(const string& s,int n) {
    string ans;
    if(n<0) return ans;
    for(int i=0;i<n;i++) ans+=s;
    return ans;
}


static void printIndentStart(){ cout<<"    0"; }
static void printShift(int t){ cout<<" [s"<<t<<"] -> "<<t; }
static void printReduce(int p){ cout<<" [r"<<p<<"]"; }
static void printPopTo(int st){ cout<<" <- "<<st; }
static void printGotoPush(int t){ cout<<" -> "<<t<<"\n      "; }



// Table handling

unordered_map<string,string>SYMBOL_TABLE;
string L_VALUE, R_VALUE;

struct Stack_element{
    int state;
    // instead of union and later separating, ima keep two bools for str or int
    bool hasStr = false;
    bool hasInt = false;

    string strVal;
    int intVal;
};

struct Action{
    char kind = ' ';
    int num = -1;
};

// parsing table 
map<pair<int,int>,Action> ACTION;
map<pair<int,string>,int>GOTO;

//productions to do
struct Prod{
    string head;
    int rhs;
};
vector<Prod>PRODS;

//fill table

static void initTable(){
    PRODS.resize(11);
    PRODS[1]={"L",3};
    PRODS[2]={"E",2};
    PRODS[3]={"R",0};
    PRODS[4]={"R",2};
    PRODS[5]={"A",2};
    PRODS[6]={"X",0};
    PRODS[7]={"X",2};
    PRODS[8]={"B",1};
    PRODS[9]={"B",1};
    PRODS[10]={"B",3};


    auto A=[&](int s,int token1,char k,int n){ 
        ACTION [{s,token1}]={k,n};

    };
    auto G=[&](int s,string nt,int to){ 
        GOTO[{s,nt}]=to; 

    };


    A(0,ID,'s',2); G(0,"L",1);
   
    A(1,EOL,'a',0);


    A(2,ASG,'s',5);

    A(3,RPN,'r',2); A(3,EOL,'r',2);
  
    A(4,EOL,'r',1);


    A(5,STR,'s',11); A(5,REF,'s',12); A(5,LPN,'s',10);
    G(5,"E",4); G(5,"A",6); G(5,"B",15);

    A(6,PLUS,'s',7); A(6,RPN,'r',3); A(6,EOL,'r',3);
    G(6,"R",3);
   
    A(7,STR,'s',11); A(7,REF,'s',12); A(7,LPN,'s',10);
    G(7,"E",13); G(7,"A",6); G(7,"B",15);

    A(8,RPN,'s',9);
   
    A(9,CRT,'r',10); A(9,PLUS,'r',10); A(9,RPN,'r',10); A(9,EOL,'r',10);

    A(10,STR,'s',11); A(10,REF,'s',12); A(10,LPN,'s',10);
    G(10,"E",8); G(10,"A",6); G(10,"B",15);
 
    A(11,CRT,'r',8); A(11,PLUS,'r',8); A(11,RPN,'r',8); A(11,EOL,'r',8);
    
    A(12,CRT,'r',9); A(12,PLUS,'r',9); A(12,RPN,'r',9); A(12,EOL,'r',9);
   
    A(13,RPN,'r',4); A(13,EOL,'r',4);

    A(14,PLUS,'r',5); A(14,RPN,'r',5); A(14,EOL,'r',5);

    A(15,CRT,'s',16); A(15,PLUS,'r',6); A(15,RPN,'r',6); A(15,EOL,'r',6);
    G(15,"X",14);

    A(16,NUM,'s',17);

    A(17,PLUS,'r',7); A(17,RPN,'r',7); A(17,EOL,'r',7);
}


// pop k with printing
static void doPops(vector<Stack_element>& st,int k){
    for(int i=0;i<k;i++){
        if(!st.empty()) st.pop_back();
        int top=st.empty()?-1:st.back().state;
        if(top>=0) printPopTo(top);
    }
}


bool parse_code(){
    if(lookahead.code == 0) lookahead = getToken();

    //handle eof , no lookahead next and last lookahead is 0 
    if(lookahead.code == 0) return false; 
    //that is exit loop

    cout<<"+++ Going to parse next statement\n";

    //using vector implementation for stack

    vector<Stack_element> stk;
    stk.push_back({0});
    printIndentStart();

    string lhs;

    while(true){
        int s=stk.back().state;

        int a=lookahead.code==0?EOL:lookahead.code;        // i am treating EOF as EOL for final reduction

        if(s==1 && a==EOL){
            cout<<" -> ACCEPT\n";
            cout<<"+++ Stored "<<L_VALUE<<" = "<<R_VALUE<<"\n\n";
            lookahead = getToken();
            return true;
        }
        Action act=ACTION[{s,a}];

        // empty means error (neighter shift or reduce or Accept)
        if(act.kind==' '){
            cerr<<"\n*** parse error state "<<s<<" wiht token "<<a<<"\n";
            cerr<<"Exiting Program !\n\n";
            exit(1);
        }

        //shift -> now we check where it shifts

        if(act.kind=='s'){

            int t=act.num;
            printShift(t);

            Stack_element node; node.state=t;

            if(a==ID){       node.hasStr=true; node.strVal=lookahead.sval; lhs=lookahead.sval; }
            else if(a==STR){ node.hasStr=true; node.strVal=lookahead.sval; }
            else if(a==REF){ node.hasStr=true; node.strVal=lookahead.sval; }
            else if(a==NUM){ node.hasInt=true; node.intVal=lookahead.ival; }
            stk.push_back(node);
            lookahead=getToken();
            continue;
        }

        if(act.kind=='r'){
            int p=act.num;

            printReduce(p);

            const auto& pr=PRODS[p];
            int k=pr.rhs; //holds the length of production

            Stack_element head; 
            if(p==1){
                string Eval=stk.back().hasStr?stk.back().strVal:"";
                SYMBOL_TABLE[lhs]=Eval;
                L_VALUE=lhs; R_VALUE=Eval;
            } else if(p==2){
                string Av=stk[stk.size()-2].strVal;
                string Rv=stk.back().strVal;
                head.hasStr=true; head.strVal=Av+Rv;
            } else if(p==3){
                head.hasStr=true; head.strVal="";
            } else if(p==4){
                head.hasStr=true; head.strVal=stk.back().strVal;
            } else if(p==5){
                string Bv=stk[stk.size()-2].strVal;
                int Xn=stk.back().intVal;
                head.hasStr=true; head.strVal=expostring(Bv,Xn);
            } else if(p==6){
                head.hasInt=true; head.intVal=1;
            } else if(p==7){
                head.hasInt=true; head.intVal=stk.back().intVal;
            } else if(p==8){
                head.hasStr=true; head.strVal=stk.back().strVal;
            } else if(p==9){
                string raw=stk.back().strVal;
                string id=(raw.size()&&raw[0]=='$')?raw.substr(1):raw;
                head.hasStr=true; 

                // check for undefined variable 
                if(SYMBOL_TABLE.count(id))
                    head.strVal = SYMBOL_TABLE[id];
                else{
                    cerr << "\n*** Reference to Undefined variable \"" << id << "\"";
                    cerr << "\n*** Substituting Empty String \n";
                    head.strVal = "";  // Set to empty string as fallback
                }
            
            } else if(p==10){
                head.hasStr=true; head.strVal=stk[stk.size()-2].strVal;
            }

            doPops(stk,k);
            int sPrime=stk.back().state;
            int go=GOTO[{sPrime,pr.head}];
            head.state=go;
            stk.push_back(head);
            printGotoPush(go);
            continue;
        }



        if(act.kind=='a'){
            cout<<" -> ACCEPT\n";
            return true;
        }
    }



}



int main(int argc, char ** argv){
    if(argc > 1){
        yyin = fopen(argv[1],"r");

    }
    cout<<"\n\n";
    initTable();
    while(parse_code());

    cout <<"Program Terminated Successfully! ('>') \n";
    cout <<"                                ( / / ) \n\n";
    return 0;
}