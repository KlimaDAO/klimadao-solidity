import json
import sys


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports": 
            sys.exit(0)

    # load both the context and the book representations from stdin
    context, book = json.load(sys.stdin)

    # and now, we can just modify the content of the first chapter
    book['sections'][1]['PartTitle'] = 'Contracts'

    # Specify the file path to save the modified book JSON
    # output_file = "modified_book.json"

    # Write the modified book JSON to the specified file
    # with open(output_file, "w") as file:
    #     json.dump(book, file, indent=2)

    print(json.dumps(book))