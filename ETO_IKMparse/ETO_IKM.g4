grammar ETO_IKM;

start:	LineTerminator* nodeDeclaration* EOF;



expression
 : expression Period identifier                  # MemberDotExpression
 | expression arguments                          # ArgumentsExpression
 | '+' expression                                # UnaryPlusExpression
 | '-' expression                                # UnaryMinusExpression
 | intentName                                    # IntentNameExpression
 | refchain                                      # RefchainExpression
 | Literal                                       # LiteralExpression
 | collectionInitializer                         # ArrayLiteralExpression
 ;
 

childMemberDeclaration: Child identifier As (intentName | expression) LineTerminator+ 
        (statement statementTerminator)*
        End Child statementTerminator;

ruleMemberDeclaration: Parent? Rule identifier ( As typeName )? Equals expression LineTerminator+;

nodeDeclaration: Node refchain? LineTerminator+ 
	nodeMemberDeclaration*
End Node statementTerminator
	;
	
nodeMemberDeclaration:
	ruleMemberDeclaration
    | childMemberDeclaration
    ;


statement:	assignmentStatement;
block:	(statement statementTerminator)+;

assignmentStatement:	expression Equals expression;

arguments
 : OpenParenthesis argumentList? CloseParenthesis
 ;
 argumentList: expression? ( Comma expression? )*;

collectionInitializer:	OpenCurlyBrace collectionElementList? CloseCurlyBrace;
collectionElementList:	collectionElement ( Comma collectionElement )*;
collectionElement:	expression | collectionInitializer;


//13.1.4 Literals
Literal:	BooleanLiteral | IntegerLiteral | FloatingPointLiteral | StringLiteral | NoValue;
fragment BooleanLiteral:	TRUE | FALSE;
fragment IntegerLiteral:	IntegralLiteralValue;
fragment IntegralLiteralValue:	IntLiteral;
fragment IntLiteral:	NumericCharacter+;
fragment FloatingPointLiteral:	FloatingPointLiteralValue | IntLiteral;
fragment FloatingPointLiteralValue:	IntLiteral '.' IntLiteral Exponent? | '.' IntLiteral Exponent? | IntLiteral Exponent;
fragment Exponent:	'E' Sign? IntLiteral;
fragment Sign:	'+' | '-';
fragment StringLiteral:	DoubleQuoteCharacter StringCharacter* DoubleQuoteCharacter;
fragment DoubleQuoteCharacter:	'"' | '\u201c' | '\u201D';
// ANTLR doesn't have a way to specify 'anything that isn't equal to a token' (like DoubleQuoteCharacter) so have to re-type it.
fragment StringCharacter:	~('"' | '\u201c' | '\u201D') | DoubleQuoteCharacter DoubleQuoteCharacter;


//13.3.3 Types
typeName:	simpleTypeName | intentName;
intentName: Colon (keyword | identifier);
simpleTypeName:	identifier | /*Name |*/ Any | Number | Integer | Boolean | String;
refchain: identifier ( Period identifierOrKeyword )*;
identifierOrKeyword:	identifier | keyword;


//13.1.3 Keywords
keyword:	/*Name |*/ Any | As | Boolean | Child | End | Integer | New | NoValue | Number | Or | Parent | Rule | String | FALSE | TRUE;
Any: 'Any' ; As: ('a'|'A') 's' ; Boolean: 'Boolean' ; End: 'End' ; Integer: 'Integer' ; New: 'New' ; NoValue: 'NoValue' ; Or: ('o'|'O') 'r' ; Parent: 'Parent' ; String: 'String' ; FALSE: 'FALSE' ; TRUE: 'TRUE';
Rule: 'Rule';
Node: 'Node';
Child: 'Child';
Number: 'Number';
//Name: 'Name';
    
//13.1.2 Identifiers
identifier: ((PRCNT PRCNT) | PRCNT )? standardIdentifier;
standardIdentifier:	IdentifierName | Child;
fragment EscapedIdentifier:	'[' IdentifierName ']';
IdentifierName:	IdentifierStart IdentifierCharacter*;
fragment IdentifierStart:	AlphaCharacter | UnderscoreCharacter IdentifierCharacter;
fragment IdentifierCharacter:	UnderscoreCharacter | AlphaCharacter | NumericCharacter | QM | PRCNT ;
fragment AlphaCharacter:	[A-Za-z];
fragment NumericCharacter:	[0-9];
fragment UnderscoreCharacter:	'_';



//13.1.1 Characters and Lines
statementTerminator:	LineTerminator+;
fragment Character:	~('\r' | '\n' | '\u2028' | '\u2029'); //'<Any Unicode character except a LineTerminator>';
LineContinuation:	WhiteSpace+ '_' WhiteSpace* LineTerminator -> channel(HIDDEN)
;
Comma:	CommaWithoutTerminator ('_'? LineTerminator)?; //Apparently in ETO the space isn't required before the line continuation underscore.
CommaWithoutTerminator: ',';
Period:	'.' LineTerminator?;
OpenParenthesis:	'(' LineTerminator?;
CloseParenthesis:	LineTerminator? ')';
OpenCurlyBrace:	'{' LineTerminator?;
CloseCurlyBrace:	LineTerminator? '}';
Equals:	'=';
Colon: ':';
QM: '?';
PRCNT: '%';
AMP: '&';
LineTerminator:	'\r' | '\n' | '\u2028' | '\u2029';
fragment WhiteSpace:	[\t\u0020];
Comment
    :	CommentMarker Character* -> channel(HIDDEN)
;
CommentMarker:	SingleQuoteCharacter | 'REM';
SingleQuoteCharacter:	'\'' | '\u2018' | '\u2019';

WhiteSpaces
 : WhiteSpace+ -> channel(HIDDEN)
 ;
