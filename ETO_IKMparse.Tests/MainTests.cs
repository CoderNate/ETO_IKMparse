using System;
using System.Linq;
using NUnit.Framework;

namespace ETO_IKMparse.Tests
{
    [TestFixture]
    public class MainTests
    {

        private static string GetTestIKMtext()
        {
            var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("ETO_IKMparse.Tests.TestIKM.ikm");
            string ikmText;
            using (var myReader = new System.IO.StreamReader(stream))
            {
                ikmText = myReader.ReadToEnd();
            }
            //Antlr parser needs a line feed at the end of the text or else the last node in the IKM won't be matched correctly.
            if (ikmText.Last() != '\n')
                ikmText += "\n";
            return ikmText;
        }

        [Test]
        public void ParseTest()
        {
            var sourceText = GetTestIKMtext();
            var parseResult = new ETO_IKMparse.IKMParser().Parse(sourceText);
            Assert.IsFalse(parseResult.ErrorMessages.Any());
            var visitResult = new TestVisitor().Visit(parseResult.ParseTree);
        }


        [Test]
        public void RewriteTest()
        {
            var sourceText = GetTestIKMtext();
            var parseResult = new ETO_IKMparse.IKMParser().Parse(sourceText);
            var rewriter = new Antlr4.Runtime.TokenStreamRewriter(parseResult.TokenStream);
            var visitResult = new TestRewriteVisitor(rewriter).Visit(parseResult.ParseTree);
            var rewrittenText = rewriter.GetText();
            Assert.IsTrue(rewrittenText.Contains(TestRewriteVisitor.NewRuleName));
        }

        private class TestVisitor : ETO_IKMparse.ETO_IKMBaseVisitor<object>
        {
        }

        private class TestRewriteVisitor : ETO_IKMparse.ETO_IKMBaseVisitor<object>
        {
            public const string NewRuleName = "TEST";

            public TestRewriteVisitor(Antlr4.Runtime.TokenStreamRewriter rewriter)
            {
                _rewriter = rewriter;
            }
            private readonly Antlr4.Runtime.TokenStreamRewriter _rewriter;

            public override object VisitRuleMemberDeclaration(ETO_IKMParser.RuleMemberDeclarationContext context)
            {
                _rewriter.Replace(context.identifier().Start, context.identifier().Stop, NewRuleName);
                return base.VisitRuleMemberDeclaration(context);
            }
        }

    }

}
