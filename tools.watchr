def growl(title, message)
	system %{growlnotify -m "#{message}" "#{title}"}
end

def reek(file)
	output = %x{reek #{file}}

	puts output

	file, warnings = output.split("\n").first.split(" -- ")

	growl "REEK: #{file}", warnings
end

def yard
	system %{yard doc {app,lib}/**/*.rb}
end

watch('(app|lib)/(.*)\.rb') { |match|
	reek(match[0])
	yard
}
