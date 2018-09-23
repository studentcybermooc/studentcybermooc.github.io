# TODO Theme Gohugo

archetypes
	default.md
	post.md
	section.md
	page.md
exampleSite
layouts
	_default
		list.html
		single.html
	partials
		footer.html
		header.html
	404.html
	index.html
static
	css
		main.css
	js
		main.js



faire css d'un post
https://gohugo.io/templates/single-page-templates/

article, sidebar (?) with ToC, wordcounts, time_to_read

<main>
    <article>
	    <header>
	        <h1>{{ .Title }}</h1>
	    </header>
        {{ .Content }}
    </article>
    <aside>
    	{{ .ReadingTime }} minutes read
    	{{ .WordCount }}
    	{{ .Date.Format "2 Jan 2006" }}
        {{ .TableOfContents }}
    </aside>
</main>