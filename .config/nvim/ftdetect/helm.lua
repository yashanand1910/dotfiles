-- Add rules to detect Helm files based on file path or extension
vim.filetype.add({
	pattern = {
		-- Detect files in a "templates" directory
		[".*/templates/.*%.yaml"] = "helm",
		[".*/templates/.*%.tpl"] = "helm",
		-- Detect files with specific Helm extensions
		["%.gotmpl"] = "helm",
		["helmfile.*%.yaml"] = "helm",
	},
})
