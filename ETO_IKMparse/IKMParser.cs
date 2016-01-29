using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Antlr4.Runtime;

namespace ETO_IKMparse
{
    public class IKMParser
    {

        public ParseResult Parse(string sourceText)
        {
            using (var memStream = new System.IO.MemoryStream(System.Text.Encoding.UTF8.GetBytes(sourceText)))
            {
                return Parse(memStream);
            }
        }
        public ParseResult Parse(System.IO.Stream sourceTextStream)
        {
            var errorMessages = new List<string>();
            AntlrInputStream input = new AntlrInputStream(sourceTextStream);
            var lexer = new ETO_IKMLexer(input);
            lexer.AddErrorListener(new LexerErrorListener() { OutputErrorFunc = msg => errorMessages.Add(msg) });
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            var parser = new ETO_IKMParser(tokens);
            parser.AddErrorListener(new ErrListener() { OutputErrorFunc = msg => errorMessages.Add(msg) });
            Antlr4.Runtime.Tree.IParseTree tree = parser.start();
            //treeAsString = tree.ToStringTree(parser);
            //System.Diagnostics.Debug.WriteLine(treeAsString);
            return new ParseResult(tokens, tree, errorMessages);
        }

        private class ErrListener : Antlr4.Runtime.BaseErrorListener
        {

            public Action<string> OutputErrorFunc;

            public override void SyntaxError(IRecognizer recognizer, IToken offendingSymbol, int line, int charPositionInLine, string msg, RecognitionException e)
            {
                base.SyntaxError(recognizer, offendingSymbol, line, charPositionInLine, msg, e);
                OutputErrorFunc(string.Format("{0} at line {1}, pos {2}", msg, line, charPositionInLine));
            }
        }

        private class LexerErrorListener : Antlr4.Runtime.IAntlrErrorListener<int>
        {
            public Action<string> OutputErrorFunc;

            void IAntlrErrorListener<int>.SyntaxError(IRecognizer recognizer, int offendingSymbol, int line, int charPositionInLine, string msg, RecognitionException e)
            {
                OutputErrorFunc(string.Format("{0} at line {1}, pos {2}", msg, line, charPositionInLine));
            }
        }

    }


    public class ParseResult
    {
        internal ParseResult(ITokenStream tokenStream, Antlr4.Runtime.Tree.IParseTree parseTree, IEnumerable<string> errorMessages)
        {
            _tokenStream = tokenStream;
            _parseTree = parseTree;
            _errorMessages = errorMessages;
        }

        private readonly ITokenStream _tokenStream;
        public ITokenStream TokenStream { get { return _tokenStream; } }

        private readonly Antlr4.Runtime.Tree.IParseTree _parseTree;
        public Antlr4.Runtime.Tree.IParseTree ParseTree { get { return _parseTree; } }

        private readonly IEnumerable<string> _errorMessages;
        public IEnumerable<string> ErrorMessages { get { return _errorMessages; } }
    }
}
