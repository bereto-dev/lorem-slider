import Foundation

enum LoremGenerator {
    private static let words: [String] = """
    lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud
    exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute
    irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
    nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui
    officia deserunt mollit anim id est laborum sed ut perspiciatis unde omnis iste
    natus error sit voluptatem accusantium doloremque laudantium totam rem aperiam
    eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae
    dicta sunt explicabo nemo enim ipsam voluptatem quia voluptas sit aspernatur
    aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione
    voluptatem sequi nesciunt neque porro quisquam est qui dolorem ipsum quia dolor
    sit amet consectetur adipisci velit sed quia non numquam eius modi tempora
    incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad
    minima veniam quis nostrum exercitationem ullam corporis suscipit laboriosam
    nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit
    qui in ea voluptate velit esse quam nihil molestiae consequatur vel illum qui
    dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus et
    iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti
    atque corrupti quos dolores et quas molestias excepturi sint occaecati
    cupiditate non provident similique sunt in culpa qui officia deserunt mollitia
    animi id est laborum et dolorum fuga et harum quidem rerum facilis est et
    expedita distinctio nam libero tempore cum soluta nobis est eligendi optio
    cumque nihil impedit quo minus id quod maxime placeat facere possimus omnis
    voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et
    aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates
    repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a
    sapiente delectus ut aut reiciendis voluptatibus maiores alias consequatur aut
    perferendis doloribus asperiores repellat
    """.split(separator: "\n").joined(separator: " ").split(separator: " ").map(String.init)

    static func generate(wordCount: Int) -> String {
        guard wordCount > 0 else { return "" }
        // Starting from a random point in the word list each time (instead of always
        // index 0) means copying the same word count twice in a row doesn't paste the
        // exact same text both times.
        let start = Int.random(in: 0..<words.count)
        var result: [String] = []
        result.reserveCapacity(wordCount)
        for i in 0..<wordCount {
            result.append(words[(start + i) % words.count])
        }
        var text = result.joined(separator: " ")
        text = text.prefix(1).uppercased() + text.dropFirst()
        text += "."
        return text
    }
}
